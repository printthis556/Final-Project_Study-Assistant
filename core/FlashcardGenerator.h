#ifndef CORE_FLASHCARD_GENERATOR_H
#define CORE_FLASHCARD_GENERATOR_H

#include "Flashcard.h"
#include <QVector>
#include <QString>

class FlashcardGenerator
{
public:
    FlashcardGenerator() = default;

    QVector<Flashcard> generateFromText(const QString &notes) const;
};

#endif // CORE_FLASHCARD_GENERATOR_H
