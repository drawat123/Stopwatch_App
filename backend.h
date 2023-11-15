#ifndef BACKEND_H
#define BACKEND_H

#include <QDateTime>
#include <QObject>
#include <QTimer>
#include <QVariant>
#include <QtDebug>
#include <chrono>

class Backend : public QObject
{
    Q_OBJECT
public:
    explicit Backend(QObject *parent = nullptr);

signals:
    void notice(QVariant data);

private slots:
    void timeout();

public slots:
    void start();
    void stop();
    void resume();
    void reset();

private:
    QTimer m_Timer;
    std::chrono::time_point<std::chrono::high_resolution_clock> m_TimerStartPoint;
    int m_ElapsedMilliseconds;
    QString m_Display;
};

#endif // BACKEND_H
