#include "Thread.h"

namespace Thread {
    bool CreateDetachedThread(void* (*func)(void*), void* arg) {
        pthread_t thread;
        pthread_attr_t attr;

        if (pthread_attr_init(&attr) != 0) {
            return false;
        }

        if (pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED) != 0) {
            pthread_attr_destroy(&attr);
            return false;
        }

        bool success = (pthread_create(&thread, &attr, func, arg) == 0);
        pthread_attr_destroy(&attr);

        return success;
    }

    pthread_t CreateJoinableThread(void* (*func)(void*), void* arg) {
        pthread_t thread;
        if (pthread_create(&thread, NULL, func, arg) != 0) {
            return 0;
        }
        return thread;
    }
}
