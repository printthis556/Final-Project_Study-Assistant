#include "FlashcardModel.h"

FlashcardModel::FlashcardModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int FlashcardModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid()) return 0;
    return m_cards.size();
}

QVariant FlashcardModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    const Flashcard &card = m_cards[index.row()];

    switch (role) {
    case QuestionRole:
        return card.question;
    case AnswerRole:
        return card.answer;
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> FlashcardModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[QuestionRole] = "question";
    roles[AnswerRole] = "answer";
    return roles;
}

void FlashcardModel::setFlashcards(const QVector<Flashcard> &cards)
{
    beginResetModel();
    m_cards = cards;
    endResetModel();
}
