#include "MainWindow.h"

#include <QVBoxLayout>
#include <QHBoxLayout>
#include <QFileDialog>
#include <QFile>
#include <QTextStream>
#include <QStatusBar>
#include <QHeaderView>
#include <QMessageBox>

MainWindow::MainWindow(QWidget *parent)
    : QMainWindow(parent), m_aiClient()
{
    setWindowTitle("Study Assistant");

    // Ensure AiClient has this as parent for proper QObject hierarchy
    m_aiClient.setParent(this);

    m_centralWidget = new QWidget(this);
    setCentralWidget(m_centralWidget);

    auto *mainLayout = new QVBoxLayout(m_centralWidget);

    m_notesEdit = new QTextEdit(this);
    m_notesEdit->setPlaceholderText("Paste or load notes here...");
    mainLayout->addWidget(m_notesEdit, /*stretch*/ 3);

    auto *buttonLayout = new QHBoxLayout();
    m_loadFileButton = new QPushButton("Load File", this);
    m_generateLocalButton = new QPushButton("Generate (Local)", this);
    m_generateAiButton = new QPushButton("Generate (AI)", this);
    buttonLayout->addWidget(m_loadFileButton);
    buttonLayout->addWidget(m_generateLocalButton);
    buttonLayout->addWidget(m_generateAiButton);
    buttonLayout->addStretch();
    mainLayout->addLayout(buttonLayout);

    m_flashcardTable = new QTableWidget(this);
    m_flashcardTable->setColumnCount(2);
    m_flashcardTable->setHorizontalHeaderLabels({"Question", "Answer"});
    m_flashcardTable->horizontalHeader()->setSectionResizeMode(0, QHeaderView::Stretch);
    m_flashcardTable->horizontalHeader()->setSectionResizeMode(1, QHeaderView::Stretch);
    mainLayout->addWidget(m_flashcardTable, /*stretch*/ 4);

    // Connect UI signals
    connect(m_loadFileButton, &QPushButton::clicked, this, &MainWindow::onLoadFileClicked);
    connect(m_generateLocalButton, &QPushButton::clicked, this, &MainWindow::onGenerateLocalClicked);
    connect(m_generateAiButton, &QPushButton::clicked, this, &MainWindow::onGenerateAiClicked);

    // Connect AiClient signals
    connect(&m_aiClient, &AiClient::flashcardsReady, this, &MainWindow::onAiFlashcardsReady);
    connect(&m_aiClient, &AiClient::errorOccurred, this, [this](const QString &msg){
        QMessageBox::warning(this, "AI Error", msg);
    });
}

MainWindow::~MainWindow()
{
}


void MainWindow::onLoadFileClicked()
{
    QString fileName = QFileDialog::getOpenFileName(this, "Open Notes File", QString(), "Text Files (*.txt);;All Files (*)");
    if (fileName.isEmpty()) return;
    QFile f(fileName);
    if (!f.open(QIODevice::ReadOnly | QIODevice::Text)) {
        QMessageBox::warning(this, "Open Failed", QStringLiteral("Failed to open file: %1").arg(fileName));
        return;
    }
    QString contents = QString::fromUtf8(f.readAll());
    m_notesEdit->setPlainText(contents);
}

void MainWindow::onGenerateLocalClicked()
{
    QString notes = m_notesEdit->toPlainText();
    QVector<Flashcard> cards = m_generator.generateFromText(notes);
    displayFlashcards(cards);
}

void MainWindow::onGenerateAiClicked()
{
    QString notes = m_notesEdit->toPlainText();
    if (notes.trimmed().isEmpty()) {
        QMessageBox::information(this, "No Notes", "Please enter or load notes before requesting AI generation.");
        return;
    }
    m_aiClient.requestFlashcards(notes);
}

void MainWindow::onAiFlashcardsReady(const QVector<Flashcard> &cards)
{
    displayFlashcards(cards);
}

void MainWindow::displayFlashcards(const QVector<Flashcard> &cards)
{
    m_flashcardTable->setRowCount(cards.size());
    for (int i = 0; i < cards.size(); ++i) {
        const Flashcard &f = cards.at(i);
        QTableWidgetItem *qItem = new QTableWidgetItem(f.question);
        QTableWidgetItem *aItem = new QTableWidgetItem(f.answer);
        qItem->setFlags(qItem->flags() ^ Qt::ItemIsEditable);
        aItem->setFlags(aItem->flags() ^ Qt::ItemIsEditable);
        m_flashcardTable->setItem(i, 0, qItem);
        m_flashcardTable->setItem(i, 1, aItem);
    }
}

