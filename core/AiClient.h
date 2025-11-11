#ifndef CORE_AI_CLIENT_H
#define CORE_AI_CLIENT_H

#include "Flashcard.h"
#include <QObject>
#include <QVector>
#include <QNetworkAccessManager>
#include <QString>
#include <QByteArray>

class AiClient : public QObject
{
    Q_OBJECT
public:
    explicit AiClient(QObject *parent = nullptr);

    Q_INVOKABLE void requestFlashcards(const QString &notes);

signals:
    void flashcardsReady(const QVector<Flashcard> &cards);
    void errorOccurred(const QString &message);

private slots:
    void onReplyFinished(QNetworkReply *reply);

private:
    QByteArray buildRequestBody(const QString &notes) const;
    QVector<Flashcard> parseFlashcardsFromResponse(const QByteArray &data, QString &errorOut) const;

    QNetworkAccessManager m_manager;
};

#endif // CORE_AI_CLIENT_H
