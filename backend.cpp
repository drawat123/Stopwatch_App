#include "backend.h"

Backend::Backend(QObject *parent)
    : QObject{parent}
{
    connect(&m_Timer, &QTimer::timeout, this, &Backend::timeout);
    m_Timer.setInterval(1);
    reset();
}

void Backend::timeout()
{
    auto duration = std::chrono::duration_cast<std::chrono::milliseconds>(
        std::chrono::high_resolution_clock::now() - m_TimerStartPoint);

    m_ElapsedMilliseconds = static_cast<int>(duration.count());

    // Convert milliseconds to seconds
    int totalSeconds = m_ElapsedMilliseconds / 1000;

    // Calculate minutes
    int minutes = totalSeconds / 60;

    // Calculate remaining seconds
    int seconds = totalSeconds % 60;

    // Calculate remaining milliseconds
    int remainingMilliseconds = m_ElapsedMilliseconds % 1000;

    // Format the result using QTime
    QTime time = QTime(0, minutes, seconds, remainingMilliseconds);
    m_Display = time.toString("mm:ss.zzz");

    emit notice(QVariant(m_Display));
}

void Backend::start()
{
    m_TimerStartPoint = std::chrono::high_resolution_clock::now();
    m_Timer.start();
}

void Backend::stop()
{
    m_Timer.stop();
}

void Backend::resume()
{
    m_TimerStartPoint = std::chrono::high_resolution_clock::now()
                        - std::chrono::milliseconds(m_ElapsedMilliseconds);
    m_Timer.start();
}

void Backend::reset()
{
    m_Timer.stop();
    m_Display = "00:00.000";
    m_TimerStartPoint = std::chrono::high_resolution_clock::now();
    m_ElapsedMilliseconds = 0;
    emit notice(QVariant(m_Display));
}
