#ifndef MAINWINDOW_H
#define MAINWINDOW_H

#include <QMainWindow>
#include <QTextEdit>
#include <QPushButton>
#include <QTableWidget>
#include <QVector>

#include "core/FlashcardGenerator.h"
#include "core/AiClient.h"
#include "core/Flashcard.h"

class MainWindow : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget *parent = nullptr);
    ~MainWindow();

private slots:
    void onLoadFileClicked();
    void onGenerateLocalClicked();
    void onGenerateAiClicked();
    void onAiFlashcardsReady(const QVector<Flashcard> &cards);

private:
    QWidget *m_centralWidget = nullptr;

    QTextEdit *m_notesEdit = nullptr;
    QPushButton *m_loadFileButton = nullptr;
    QPushButton *m_generateLocalButton = nullptr;
    QPushButton *m_generateAiButton = nullptr;
    QTableWidget *m_flashcardTable = nullptr;

    FlashcardGenerator m_generator;
    AiClient m_aiClient;

    void displayFlashcards(const QVector<Flashcard> &cards);
};

#endif // MAINWINDOW_H
