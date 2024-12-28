#include <pthread.h>

namespace Thread {
    typedef void* (*ThreadFunction)(void*);

    // Create and start a detached thread with arguments
    bool CreateDetachedThread(ThreadFunction func, void* arg = nullptr);

    // Create and start a joinable thread with arguments
    pthread_t CreateJoinableThread(ThreadFunction func, void* arg = nullptr);
}
