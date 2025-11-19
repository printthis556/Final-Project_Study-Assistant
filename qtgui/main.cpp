#include <QApplication>
#include "MainWindow.h"

int main(int argc, char *argv[])// this is argument counting the number of command line arguments
{
    QApplication app(argc, argv);

    MainWindow w;
    w.resize(1000, 600);
    w.show();

    return app.exec();
}
