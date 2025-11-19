#pragma once

#include <QObject>
#include <QString>
#include "BoardManager.h"
#include "FlashcardModel.h"
#include "FlashcardGenerator.h"
#include "AiClient.h"

class StudyController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(FlashcardModel* flashcardModel READ flashcardModel NOTIFY flashcardsChanged)
    Q_PROPERTY(QString lastAiAnswer READ lastAiAnswer NOTIFY lastAiAnswerChanged)
    Q_PROPERTY(bool isBusy READ isBusy NOTIFY isBusyChanged)
    Q_PROPERTY(bool useLocalFlashcards READ isUseLocalFlashcards NOTIFY useLocalFlashcardsChanged)
    Q_PROPERTY(QString lastAiRawResponse READ lastAiRawResponse NOTIFY lastAiRawResponseChanged)
    Q_PROPERTY(QString lastAiError READ lastAiError NOTIFY lastAiErrorChanged)

public:
    explicit StudyController(BoardManager *manager, AiClient *aiClient, QObject *parent = nullptr);

    FlashcardModel* flashcardModel() { return &m_flashcardModel; }
    QString lastAiAnswer() const { return m_lastAiAnswer; }
    bool isBusy() const { return m_isBusy; }

    Q_INVOKABLE void generateFlashcardsForBoard(const QString &boardId);
    Q_INVOKABLE void askAiAboutBoard(const QString &boardId, const QString &question);
    Q_INVOKABLE void setAiEndpoint(const QString &url);
    Q_INVOKABLE void setAiApiKey(const QString &key);
    Q_INVOKABLE void setUseLocalFlashcards(bool useLocal);
    bool isUseLocalFlashcards() const { return m_useLocalFlashcards; }
    QString lastAiRawResponse() const { return m_lastAiRawResponse; }
    QString lastAiError() const { return m_lastAiError; }

signals:
    void flashcardsChanged();
    void lastAiAnswerChanged();
    void isBusyChanged();
    void errorOccurred(const QString &msg);
    void useLocalFlashcardsChanged();
    void lastAiRawResponseChanged();
    void lastAiErrorChanged();

private:
    void setBusy(bool busy);
    void handleFlashcardsReady(const QVector<Flashcard> &cards);
    void handleAnswerReady(const QString &answer);
    void handleAiError(const QString &message);

    BoardManager *m_boardManager;
    AiClient *m_aiClient;
    FlashcardModel m_flashcardModel;
    FlashcardGenerator m_generator;

    QString m_lastAiAnswer;
    bool m_isBusy = false;
    bool m_useLocalFlashcards = false;
    QString m_lastAiRawResponse;
    QString m_lastAiError;
    QString m_lastNotes;
};
