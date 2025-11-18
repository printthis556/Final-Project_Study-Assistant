#include "StudyController.h"
#include <QDebug>

StudyController::StudyController(BoardManager *manager, AiClient *aiClient, QObject *parent)
    : QObject(parent),
      m_boardManager(manager),
      m_aiClient(aiClient)
{
    if (m_aiClient) {
        connect(m_aiClient, &AiClient::flashcardsReady, this, &StudyController::handleFlashcardsReady);
        connect(m_aiClient, &AiClient::answerReady, this, &StudyController::handleAnswerReady);
        connect(m_aiClient, &AiClient::errorOccurred, this, &StudyController::handleAiError);
    }
}

void StudyController::setBusy(bool busy)
{
    if (m_isBusy == busy) return;
    m_isBusy = busy;
    emit isBusyChanged();
}

void StudyController::generateFlashcardsForBoard(const QString &boardId)
{
    if (!m_boardManager) return;

    QString notes = m_boardManager->allNotesForBoard(boardId);
    if (notes.trimmed().isEmpty()) {
        emit errorOccurred("This board has no notes.");
        return;
    }

    setBusy(true);

    if (m_aiClient) {
        m_aiClient->requestFlashcards(notes);
    } else {
        QVector<Flashcard> cards = m_generator.generateFromText(notes);
        handleFlashcardsReady(cards);
    }
}

void StudyController::askAiAboutBoard(const QString &boardId, const QString &question)
{
    if (question.trimmed().isEmpty()) {
        emit errorOccurred("Please enter a question.");
        return;
    }

    if (!m_boardManager) {
        emit errorOccurred("Board manager unavailable.");
        return;
    }

    QString context = m_boardManager->allNotesForBoard(boardId);
    if (context.trimmed().isEmpty()) {
        emit errorOccurred("This board has no notes.");
        return;
    }

    setBusy(true);

    if (m_aiClient) {
        m_aiClient->requestAnswer(context, question);
    } else {
        m_lastAiAnswer = QStringLiteral("AI client not configured.");
        emit lastAiAnswerChanged();
        setBusy(false);
    }
}

void StudyController::handleFlashcardsReady(const QVector<Flashcard> &cards)
{
    m_flashcardModel.setFlashcards(cards);
    emit flashcardsChanged();
    setBusy(false);
}

void StudyController::handleAnswerReady(const QString &answer)
{
    m_lastAiAnswer = answer;
    emit lastAiAnswerChanged();
    setBusy(false);
}

void StudyController::handleAiError(const QString &message)
{
    emit errorOccurred(message);
    setBusy(false);
}
