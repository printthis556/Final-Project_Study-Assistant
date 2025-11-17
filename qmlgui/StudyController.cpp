#include "StudyController.h"
#include <QDebug>

StudyController::StudyController(BoardManager *manager, QObject *parent)
    : QObject(parent),
      m_boardManager(manager)
{
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

    QVector<Flashcard> cards = m_generator.generateFromText(notes);
    m_flashcardModel.setFlashcards(cards);

    emit flashcardsChanged();
    setBusy(false);
}

void StudyController::askAiAboutBoard(const QString &boardId, const QString &question)
{
    if (question.trimmed().isEmpty()) {
        emit errorOccurred("Please enter a question.");
        return;
    }

    setBusy(true);

    QString context = m_boardManager->allNotesForBoard(boardId);

    // Fake AI for now — replace with AiClient when ready
    m_lastAiAnswer =
        QString("AI Response (placeholder):\n\nQ: %1\n\nNotes size: %2 characters")
        .arg(question)
        .arg(context.size());

    emit lastAiAnswerChanged();
    setBusy(false);
}
