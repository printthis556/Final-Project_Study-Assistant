#pragma once

#include <QAbstractListModel>
#include <QVector>
#include "Flashcard.h"

class FlashcardModel : public QAbstractListModel
{
    Q_OBJECT
public:
    enum Roles {
        QuestionRole = Qt::UserRole + 1,
        AnswerRole
    };

    explicit FlashcardModel(QObject *parent = nullptr);

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;

    void setFlashcards(const QVector<Flashcard> &cards);
    const QVector<Flashcard>& flashcards() const { return m_cards; }

private:
    QVector<Flashcard> m_cards;
};
