#ifndef CORE_AI_CLIENT_H
#define CORE_AI_CLIENT_H

#include "Flashcard.h"
#include <QObject>
#include <QVector>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QString>
#include <QByteArray>
#include <QUrl>

class AiClient : public QObject
{
    Q_OBJECT
public:
    explicit AiClient(QObject *parent = nullptr);

    Q_INVOKABLE void requestFlashcards(const QString &notes);
    Q_INVOKABLE void requestAnswer(const QString &notes, const QString &question);

signals:
    void flashcardsReady(const QVector<Flashcard> &cards);
    void answerReady(const QString &answer);
    void errorOccurred(const QString &message);

private slots:
    void onReplyFinished(QNetworkReply *reply);

private:
    QByteArray buildRequestBody(const QString &notes) const;
    QByteArray buildAskBody(const QString &notes, const QString &question) const;
    QVector<Flashcard> parseFlashcardsFromResponse(const QByteArray &data, QString &errorOut) const;
    QString parseAnswerFromResponse(const QByteArray &data, QString &errorOut) const;
    QUrl apiEndpoint() const;

    QNetworkAccessManager m_manager;
};

#endif // CORE_AI_CLIENT_H
