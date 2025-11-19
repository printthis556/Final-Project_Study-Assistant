#include "AiClient.h"

#include <QNetworkRequest>
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonValue>
#include <QUrl>
#include <QNetworkReply>
#include <QDebug>
#include <QCoreApplication>
#include <QByteArray>

AiClient::AiClient(QObject *parent)
    : QObject(parent)
{
    connect(&m_manager, &QNetworkAccessManager::finished,
            this, &AiClient::onReplyFinished);
}

void AiClient::setEndpointOverride(const QString &url)
{
    m_endpointOverride = url.trimmed();
}

void AiClient::setApiKeyOverride(const QString &key)
{
    m_apiKeyOverride = key.toUtf8();
}

void AiClient::requestFlashcards(const QString &notes)
{
    if (notes.trimmed().isEmpty()) {
        emit errorOccurred(QStringLiteral("Notes input is empty."));
        return;
    }

    QUrl url = flashcardsEndpoint();
    if (!url.isValid()) {
        emit errorOccurred(QStringLiteral(
            "AI flashcard endpoint is invalid. Set AI_FLASHCARDS_ENDPOINT or AI_API_ENDPOINT."));
        return;
    }
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));

    // If AI_API_KEY env var exists, add Authorization header
    QByteArray apiKey;
    if (!m_apiKeyOverride.isEmpty()) {
        apiKey = m_apiKeyOverride;
    } else {
        apiKey = qgetenv("AI_API_KEY");
    }
    if (!apiKey.isEmpty()) {
        QByteArray bearer = "Bearer " + apiKey;
        req.setRawHeader("Authorization", bearer);
    }

    QByteArray body = buildRequestBody(notes);
    QNetworkReply *reply = m_manager.post(req, body);
    if (reply) {
        reply->setProperty("ai_request_type", QByteArrayLiteral("flashcards"));
    }
}

void AiClient::requestAnswer(const QString &notes, const QString &question)
{
    if (question.trimmed().isEmpty()) {
        emit errorOccurred(QStringLiteral("Question cannot be empty."));
        return;
    }

    QUrl url = askEndpoint();
    if (!url.isValid()) {
        emit errorOccurred(QStringLiteral(
            "AI ask endpoint is invalid. Set AI_ASK_ENDPOINT or AI_API_ENDPOINT."));
        return;
    }

    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));

    QByteArray apiKey2;
    if (!m_apiKeyOverride.isEmpty()) {
        apiKey2 = m_apiKeyOverride;
    } else {
        apiKey2 = qgetenv("AI_API_KEY");
    }
    if (!apiKey2.isEmpty()) {
        QByteArray bearer = "Bearer " + apiKey2;
        req.setRawHeader("Authorization", bearer);
    }

    QByteArray body = buildAskBody(notes, question);
    QNetworkReply *reply = m_manager.post(req, body);
    if (reply) {
        reply->setProperty("ai_request_type", QByteArrayLiteral("ask"));
    }
}

QByteArray AiClient::buildRequestBody(const QString &notes) const
{
    QJsonObject root;
    root.insert(QStringLiteral("task"), QStringLiteral("flashcards"));
    root.insert(QStringLiteral("notes"), notes);
    root.insert(QStringLiteral("max_flashcards"), 30);
    root.insert(QStringLiteral("instructions"),
                QStringLiteral("Return a JSON array of objects with fields 'question' and 'answer'."));

    QJsonDocument doc(root);
    return doc.toJson(QJsonDocument::Compact);
}

QByteArray AiClient::buildAskBody(const QString &notes, const QString &question) const
{
    QJsonObject root;
    root.insert(QStringLiteral("task"), QStringLiteral("ask"));
    root.insert(QStringLiteral("notes"), notes);
    root.insert(QStringLiteral("question"), question);
    root.insert(QStringLiteral("instructions"), QStringLiteral(
                     "Answer the question using the provided notes as context."));

    QJsonDocument doc(root);
    return doc.toJson(QJsonDocument::Compact);
}

QVector<Flashcard> AiClient::parseFlashcardsFromResponse(const QByteArray &data, QString &errorOut) const
{
    QVector<Flashcard> out;
    errorOut.clear();

    if (data.isEmpty()) {
        errorOut = QStringLiteral("Empty response body from AI endpoint.");
        return out;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        errorOut = QStringLiteral("Failed to parse JSON response: %1").arg(parseError.errorString());
        return out;
    }

    QJsonArray arr;
    if (doc.isArray()) {
        arr = doc.array();
    } else if (doc.isObject()) {
        QJsonObject obj = doc.object();
        // Accept either "flashcards" or "cards" payloads when the backend wraps the data.
        if (obj.value(QStringLiteral("flashcards")).isArray()) {
            arr = obj.value(QStringLiteral("flashcards")).toArray();
        } else if (obj.value(QStringLiteral("cards")).isArray()) {
            arr = obj.value(QStringLiteral("cards")).toArray();
        } else if (obj.value(QStringLiteral("data")).isArray()) {
            // Some APIs wrap results in a `data` array.
            arr = obj.value(QStringLiteral("data")).toArray();
        } else if (obj.value(QStringLiteral("result")).isArray()) {
            arr = obj.value(QStringLiteral("result")).toArray();
        } else if (obj.contains(QStringLiteral("choices")) && obj.value(QStringLiteral("choices")).isArray()) {
            // Handle OpenAI-style responses where choices[0].message.content contains
            // a JSON string representing the array of flashcards. Try to extract
            // and parse that JSON string.
            QJsonArray choices = obj.value(QStringLiteral("choices")).toArray();
            if (!choices.isEmpty() && choices.first().isObject()) {
                QJsonObject choiceObj = choices.first().toObject();
                // Support both older and newer OpenAI shapes
                QJsonValue messageVal = choiceObj.value(QStringLiteral("message"));
                if (messageVal.isObject()) {
                    QJsonObject messageObj = messageVal.toObject();
                    QJsonValue contentVal = messageObj.value(QStringLiteral("content"));
                    if (contentVal.isString()) {
                        QByteArray nested = contentVal.toString().toUtf8();
                        QJsonParseError nestedErr;
                        QJsonDocument nestedDoc = QJsonDocument::fromJson(nested, &nestedErr);
                        if (nestedErr.error == QJsonParseError::NoError) {
                            if (nestedDoc.isArray()) {
                                arr = nestedDoc.array();
                            } else if (nestedDoc.isObject()) {
                                QJsonObject nestedObj = nestedDoc.object();
                                if (nestedObj.value(QStringLiteral("flashcards")).isArray()) {
                                    arr = nestedObj.value(QStringLiteral("flashcards")).toArray();
                                } else if (nestedObj.value(QStringLiteral("cards")).isArray()) {
                                    arr = nestedObj.value(QStringLiteral("cards")).toArray();
                                }
                            }
                        }
                    }
                }
            }
        } else if (obj.contains(QStringLiteral("error"))) {
            // Surface server-provided error messages.
            QJsonValue errVal = obj.value(QStringLiteral("error"));
            if (errVal.isString()) {
                errorOut = errVal.toString();
            } else if (errVal.isObject()) {
                QJsonObject errObj = errVal.toObject();
                if (errObj.contains(QStringLiteral("message")) && errObj.value(QStringLiteral("message")).isString()) {
                    errorOut = errObj.value(QStringLiteral("message")).toString();
                }
            }
        }
    }

    if (arr.isEmpty()) {
        errorOut = QStringLiteral("Unexpected JSON structure: expected an array of flashcards.");
        return out;
    }

    for (const QJsonValue &val : arr) {
        if (!val.isObject()) continue;
        QJsonObject obj = val.toObject();
        if (!obj.contains(QStringLiteral("question")) || !obj.contains(QStringLiteral("answer"))) {
            continue;
        }
        QJsonValue qv = obj.value(QStringLiteral("question"));
        QJsonValue av = obj.value(QStringLiteral("answer"));
        if (!qv.isString() || !av.isString()) continue;

        Flashcard f;
        f.question = qv.toString();
        f.answer = av.toString();
        out.append(f);
    }

    if (out.isEmpty()) {
        errorOut = QStringLiteral("No valid flashcards found in AI response.");
    }

    return out;
}

QString AiClient::parseAnswerFromResponse(const QByteArray &data, QString &errorOut) const
{
    errorOut.clear();

    if (data.isEmpty()) {
        errorOut = QStringLiteral("Empty response body from AI endpoint.");
        return QString();
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);
    if (parseError.error != QJsonParseError::NoError) {
        errorOut = QStringLiteral("Failed to parse JSON response: %1").arg(parseError.errorString());
        return QString();
    }

    if (doc.isObject()) {
        QJsonObject obj = doc.object();
        QJsonValue ansVal = obj.value(QStringLiteral("answer"));
        if (ansVal.isString()) {
            return ansVal.toString();
        }

        // Fallback: support OpenAI-style responses with choices[0].message.content
        if (obj.contains(QStringLiteral("choices")) && obj.value(QStringLiteral("choices")).isArray()) {
            QJsonArray choices = obj.value(QStringLiteral("choices")).toArray();
            if (!choices.isEmpty() && choices.first().isObject()) {
                QJsonObject choiceObj = choices.first().toObject();
                if (choiceObj.contains(QStringLiteral("message")) && choiceObj.value(QStringLiteral("message")).isObject()) {
                    QJsonObject messageObj = choiceObj.value(QStringLiteral("message")).toObject();
                    QJsonValue contentVal = messageObj.value(QStringLiteral("content"));
                    if (contentVal.isString()) {
                        return contentVal.toString();
                    }
                }
            }
        }
    }

    errorOut = QStringLiteral("No answer field found in AI response.");
    return QString();
}

QUrl AiClient::endpointFromEnv(const char *envName, const QString &fallbackEnv) const
{
    // If code has an override set at runtime, use it first.
    if (!m_endpointOverride.isEmpty()) {
        return QUrl(m_endpointOverride);
    }

    QByteArray envValue = qgetenv(envName);
    if (!envValue.isEmpty()) {
        return QUrl(QString::fromUtf8(envValue));
    }

    if (!fallbackEnv.isEmpty()) {
        QByteArray fallbackValue = qgetenv(fallbackEnv.toUtf8().constData());
        if (!fallbackValue.isEmpty()) {
            return QUrl(QString::fromUtf8(fallbackValue));
        }
    }

    return QUrl();
}

QUrl AiClient::flashcardsEndpoint() const
{
    // Prefer a dedicated flashcards endpoint, fall back to a shared AI endpoint.
    QUrl url = endpointFromEnv("AI_FLASHCARDS_ENDPOINT", QStringLiteral("AI_API_ENDPOINT"));
    if (url.isValid()) return url;

    // Default to a Cloudflare Worker that generates flashcards (if no env var set).
    return QUrl(QStringLiteral("https://ai-study-app.mhess0308.workers.dev/"));
}

QUrl AiClient::askEndpoint() const
{
    // Prefer a dedicated ask endpoint, fall back to a shared AI endpoint.
    QUrl url = endpointFromEnv("AI_ASK_ENDPOINT", QStringLiteral("AI_API_ENDPOINT"));
    if (url.isValid()) return url;

    // Default to the same Cloudflare Worker as a sensible fallback for ask requests.
    return QUrl(QStringLiteral("https://ai-study-app.mhess0308.workers.dev/"));
}

void AiClient::onReplyFinished(QNetworkReply *reply)
{
    if (!reply) {
        emit errorOccurred(QStringLiteral("Network reply pointer is null."));
        return;
    }

    QNetworkReply::NetworkError err = reply->error();
    if (err != QNetworkReply::NoError) {
        QString msg = reply->errorString();
        reply->deleteLater();
        emit errorOccurred(QStringLiteral("Network error: %1").arg(msg));
        return;
    }

    QByteArray data = reply->readAll();
    reply->deleteLater();
    // Emit raw response (UTF-8) for debugging UI to display if needed.
    emit rawResponse(QString::fromUtf8(data));
    QString requestType = reply->property("ai_request_type").toByteArray();

    QString parseError;
    if (requestType == QByteArrayLiteral("ask")) {
        QString answer = parseAnswerFromResponse(data, parseError);
        if (!parseError.isEmpty()) {
            // Include a short snippet of the raw response to aid debugging.
            QString snippet = QString::fromUtf8(data).left(800);
            QString msg = QStringLiteral("AI parse error: %1\nResponse snippet: %2").arg(parseError, snippet);
            qWarning() << msg;
            emit errorOccurred(msg);
        } else {
                qDebug() << "AiClient::onReplyFinished: answerReady" << answer.left(200);
                emit answerReady(answer);
        }
    } else {
        QVector<Flashcard> cards = parseFlashcardsFromResponse(data, parseError);
        if (!parseError.isEmpty()) {
            QString snippet = QString::fromUtf8(data).left(800);
            QString msg = QStringLiteral("AI parse error: %1\nResponse snippet: %2").arg(parseError, snippet);
            qWarning() << msg;
            emit errorOccurred(msg);
        } else {
                qDebug() << "AiClient::onReplyFinished: flashcardsReady count=" << cards.size();
                emit flashcardsReady(cards);
        }
    }
}
