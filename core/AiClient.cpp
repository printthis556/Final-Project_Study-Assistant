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

void AiClient::requestFlashcards(const QString &notes)
{
    if (notes.trimmed().isEmpty()) {
        emit errorOccurred(QStringLiteral("Notes input is empty."));
        return;
    }

    QUrl url(QStringLiteral("https://your-ai-endpoint.example.com/v1/flashcards"));
    QNetworkRequest req(url);
    req.setHeader(QNetworkRequest::ContentTypeHeader, QStringLiteral("application/json"));

    // If AI_API_KEY env var exists, add Authorization header
    QByteArray apiKey = qgetenv("AI_API_KEY");
    if (!apiKey.isEmpty()) {
        QByteArray bearer = "Bearer " + apiKey;
        req.setRawHeader("Authorization", bearer);
    }

    QByteArray body = buildRequestBody(notes);
    m_manager.post(req, body);
}

QByteArray AiClient::buildRequestBody(const QString &notes) const
{
    QJsonObject root;
    QString prompt = QStringLiteral(
        "You are an assistant that converts lecture notes into study flashcards. "
        "Return a JSON array of objects with fields \"question\" and \"answer\". "
        "Base flashcards on the text provided in the \"notes\" field. "
        "Ensure answers are concise but informative.\n\n"
    );
    root.insert(QStringLiteral("prompt"), prompt + QStringLiteral("\nNotes:\n") + notes);
    root.insert(QStringLiteral("max_flashcards"), 30);

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

    if (!doc.isArray()) {
        errorOut = QStringLiteral("Unexpected JSON structure: expected an array of flashcards.");
        return out;
    }

    QJsonArray arr = doc.array();
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

    QString parseError;
    QVector<Flashcard> cards = parseFlashcardsFromResponse(data, parseError);
    if (!parseError.isEmpty()) {
        emit errorOccurred(parseError);
    } else {
        emit flashcardsReady(cards);
    }
}
