#include "BoardManager.h"
#include <QUuid>

BoardManager::BoardManager(QObject *parent)
    : QObject(parent)
{
    // Optional default board
    QString id = createBoard("My First Board");
    selectBoard(id);
}

QVariantList BoardManager::boards() const
{
    QVariantList list;
    for (const auto &board : m_boards) {
        QVariantMap m;
        m["id"] = board.id;
        m["name"] = board.name;
        m["noteCount"] = board.notes.size();
        list.append(m);
    }
    return list;
}

QString BoardManager::currentBoardName() const
{
    auto it = m_boards.find(m_currentBoardId);
    if (it == m_boards.end())
        return QString();
    return it->name;
}

QVariantList BoardManager::currentBoardNotes() const
{
    QVariantList list;
    auto it = m_boards.find(m_currentBoardId);
    if (it == m_boards.end())
        return list;

    int index = 0;
    for (const QString &note : it->notes) {
        QVariantMap m;
        m["index"] = index++;
        QString preview = note.split("\n").value(0);
        if (preview.length() > 80)
            preview = preview.left(77) + "...";

        m["preview"] = preview;
        m["text"] = note;
        list.append(m);
    }
    return list;
}

QString BoardManager::createBoard(const QString &name)
{
    BoardData b;
    b.id = generateBoardId();
    b.name = name.isEmpty() ? "Untitled Board" : name;

    m_boards.insert(b.id, b);
    emit boardsChanged();

    return b.id;
}

void BoardManager::deleteBoard(const QString &boardId)
{
    m_boards.remove(boardId);
    if (m_currentBoardId == boardId) {
        m_currentBoardId.clear();
        emit currentBoardChanged();
        emit currentBoardNotesChanged();
    }
    emit boardsChanged();
}

void BoardManager::selectBoard(const QString &boardId)
{
    if (m_currentBoardId == boardId)
        return;

    m_currentBoardId = boardId;
    emit currentBoardChanged();
    emit currentBoardNotesChanged();
}

void BoardManager::addNoteToCurrentBoard(const QString &text)
{
    if (!m_boards.contains(m_currentBoardId))
        return;

    m_boards[m_currentBoardId].notes.append(text);
    emit currentBoardNotesChanged();
}

void BoardManager::deleteNoteFromCurrentBoard(int index)
{
    if (!m_boards.contains(m_currentBoardId))
        return;

    auto &notes = m_boards[m_currentBoardId].notes;
    if (index >= 0 && index < notes.size()) {
        notes.removeAt(index);
        emit currentBoardNotesChanged();
    }
}

QString BoardManager::allNotesForBoard(const QString &boardId) const
{
    if (!m_boards.contains(boardId))
        return QString();
    return m_boards.value(boardId).notes.join("\n\n");
}

QString BoardManager::generateBoardId() const
{
    return QUuid::createUuid().toString(QUuid::WithoutBraces);
}
