#pragma once

#include <QObject>
#include <QString>
#include "BoardManager.h"
#include "FlashcardModel.h"
#include "FlashcardGenerator.h"

class StudyController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(FlashcardModel* flashcardModel READ flashcardModel NOTIFY flashcardsChanged)
    Q_PROPERTY(QString lastAiAnswer READ lastAiAnswer NOTIFY lastAiAnswerChanged)
    Q_PROPERTY(bool isBusy READ isBusy NOTIFY isBusyChanged)

public:
    explicit StudyController(BoardManager *manager, QObject *parent = nullptr);

    FlashcardModel* flashcardModel() { return &m_flashcardModel; }
    QString lastAiAnswer() const { return m_lastAiAnswer; }
    bool isBusy() const { return m_isBusy; }

    Q_INVOKABLE void generateFlashcardsForBoard(const QString &boardId);
    Q_INVOKABLE void askAiAboutBoard(const QString &boardId, const QString &question);

signals:
    void flashcardsChanged();
    void lastAiAnswerChanged();
    void isBusyChanged();
    void errorOccurred(const QString &msg);

private:
    void setBusy(bool busy);

    BoardManager *m_boardManager;
    FlashcardModel m_flashcardModel;
    FlashcardGenerator m_generator;

    QString m_lastAiAnswer;
    bool m_isBusy = false;
};
