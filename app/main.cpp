#include <QCoreApplication>
#include <QTextStream>
#include "FlashcardGenerator.h"

int main(int argc, char **argv)
{
    QCoreApplication app(argc, argv);
    QTextStream out(stdout);

    FlashcardGenerator gen;

    // Sample notes with two topics separated by blank lines
    const QString notes = QStringLiteral(R"(Quantum Mechanics
Quantum mechanics studies the behavior of matter and energy at atomic scales.
Key ideas include wave-particle duality and uncertainty principle.

Linear Algebra
Linear algebra is the study of vectors, matrices, and linear transformations.
Important concepts: eigenvalues, eigenvectors, and matrix decompositions.)");

    QVector<Flashcard> cards = gen.generateFromText(notes);

    if (cards.isEmpty()) {
        out << "No flashcards generated.\n";
        return 0;
    }

    for (int i = 0; i < cards.size(); ++i) {
        const Flashcard &f = cards.at(i);
        out << "Flashcard " << (i + 1) << ":\n";
        out << "Q: " << f.question << "\n";
        out << "A: " << f.answer << "\n";
        out << "---------------------------\n";
    }

    return 0;
}
