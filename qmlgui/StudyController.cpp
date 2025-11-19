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
        connect(m_aiClient, &AiClient::rawResponse, this, [this](const QString &raw) {
            m_lastAiRawResponse = raw;
            emit lastAiRawResponseChanged();
        });
    }
}

void StudyController::setUseLocalFlashcards(bool useLocal)
{
    if (m_useLocalFlashcards == useLocal) return;
    m_useLocalFlashcards = useLocal;
    emit useLocalFlashcardsChanged();
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
    qDebug() << "generateFlashcardsForBoard called for boardId:" << boardId << "notes length:" << notes.length();
    if (notes.trimmed().isEmpty()) {
        emit errorOccurred("This board has no notes.");
        return;
    }

    setBusy(true);

    // If forced to use local generator, bypass AI client even when present.
    if (m_useLocalFlashcards) {
        qDebug() << "Using local FlashcardGenerator for boardId:" << boardId;
        m_lastNotes = notes;
        QVector<Flashcard> cards = m_generator.generateFromText(notes);
        handleFlashcardsReady(cards);
        return;
    }

    m_lastNotes = notes;
    if (m_aiClient) {
        qDebug() << "Requesting flashcards from AI for boardId:" << boardId;
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

void StudyController::setAiEndpoint(const QString &url)
{
    if (m_aiClient) m_aiClient->setEndpointOverride(url);
}

void StudyController::setAiApiKey(const QString &key)
{
    if (m_aiClient) m_aiClient->setApiKeyOverride(key);
}

void StudyController::handleFlashcardsReady(const QVector<Flashcard> &cards)
{
    qDebug() << "handleFlashcardsReady: got" << cards.size() << "cards";

    if (cards.isEmpty()) {
        // If AI returned nothing, fall back to deterministic local generator
        qDebug() << "AI returned 0 cards, falling back to local generator";
        QVector<Flashcard> local = m_generator.generateFromText(m_lastNotes);
        m_flashcardModel.setFlashcards(local);
        emit flashcardsChanged();
        setBusy(false);
        return;
    }

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
    qDebug() << "handleAiError:" << message;
    m_lastAiError = message;
    emit lastAiErrorChanged();

    // If AI errors and local generation is allowed, fall back to local generator
    if (!m_useLocalFlashcards) {
        qDebug() << "Falling back to local generator due to AI error.";
        QVector<Flashcard> local = m_generator.generateFromText(m_lastNotes);
        if (!local.isEmpty()) {
            m_flashcardModel.setFlashcards(local);
            emit flashcardsChanged();
            // notify user that AI failed but local generator was used
            emit errorOccurred(QStringLiteral("AI error: %1\nUsing local generator instead.").arg(message));
            setBusy(false);
            return;
        }
    }

    emit errorOccurred(message);
    setBusy(false);
}
