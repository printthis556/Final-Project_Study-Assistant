#pragma once

#include <QObject>
#include <QString>
#include <QStringList>
#include <QVariantList>
#include <QMap>

struct BoardData {
    QString id;
    QString name;
    QStringList notes;
};

class BoardManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantList boards READ boards NOTIFY boardsChanged)
    Q_PROPERTY(QString currentBoardId READ currentBoardId NOTIFY currentBoardChanged)
    Q_PROPERTY(QString currentBoardName READ currentBoardName NOTIFY currentBoardChanged)
    Q_PROPERTY(QVariantList currentBoardNotes READ currentBoardNotes NOTIFY currentBoardNotesChanged)

public:
    explicit BoardManager(QObject *parent = nullptr);

    QVariantList boards() const;
    QString currentBoardId() const { return m_currentBoardId; }
    QString currentBoardName() const;
    QVariantList currentBoardNotes() const;

    Q_INVOKABLE QString createBoard(const QString &name);
    Q_INVOKABLE void deleteBoard(const QString &boardId);
    Q_INVOKABLE void selectBoard(const QString &boardId);

    Q_INVOKABLE void addNoteToCurrentBoard(const QString &text);
    Q_INVOKABLE void deleteNoteFromCurrentBoard(int index);

    QString allNotesForBoard(const QString &boardId) const;

signals:
    void boardsChanged();
    void currentBoardChanged();
    void currentBoardNotesChanged();

private:
    QString generateBoardId() const;

    QString m_currentBoardId;
    QMap<QString, BoardData> m_boards;
};
