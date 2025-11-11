#include "FlashcardGenerator.h"
#include <QStringList>
#include <QRegularExpression>

static QString truncateTo80(const QString &s) {
    const int limit = 80;
    if (s.size() <= limit) return s;
    QString truncated = s.left(limit).trimmed();
    return truncated + QStringLiteral("...");
}

QVector<Flashcard> FlashcardGenerator::generateFromText(const QString &notes) const
{
    QVector<Flashcard> result;
    if (notes.trimmed().isEmpty()) return result;

    // Split on double newlines (blocks separated by a blank line). Be robust to \r\n.
    QRegularExpression blockSep(R"(\r?\n\s*\r?\n)");
    QStringList blocks = notes.split(blockSep, Qt::SkipEmptyParts);

    auto processBlocks = [&](const QStringList &blks) {
        for (const QString &rawBlock : blks) {
            QString block = rawBlock.trimmed();
            if (block.isEmpty()) continue;
            // First line is topic
            QString firstLine;
            int newlinePos = block.indexOf(QChar('\n'));
            if (newlinePos >= 0) {
                firstLine = block.left(newlinePos).trimmed();
            } else {
                firstLine = block.section('\n', 0, 0).trimmed();
            }
            QString question = QStringLiteral("Explain: %1").arg(truncateTo80(firstLine));
            Flashcard f;
            f.question = question;
            f.answer = block;
            result.append(f);
        }
    };

    processBlocks(blocks);

    // Fallback: if nothing produced, split by single newlines into lines and treat each as a block.
    if (result.isEmpty()) {
        QStringList lines = notes.split(QRegularExpression(R"(\r?\n)"), Qt::SkipEmptyParts);
        processBlocks(lines);
    }

    return result;
}
