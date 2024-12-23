#pragma once
#include <vector>
#include <functional>
#include <string>
#include <unordered_map>
#include <mutex>
#include <thread>
#include <atomic>
#include <chrono>

struct CacheConfig {
    std::string typeName;
    std::vector<Unity::CGameObject*>* storage;
    std::function<void(Unity::CGameObject*)> process;
};

class CacheManager {
public:
    CacheManager() : running(false) {}

    void AddCacheConfig(const std::string& typeName, std::vector<Unity::CGameObject*>& storage, std::function<void(Unity::CGameObject*)> process = nullptr) {
        std::lock_guard<std::mutex> lock(configMutex);
        configs[typeName] = { typeName, &storage, process };
    }

    void StartCaching() {
        running.store(true);
        while (running.load()) {
            {
                std::lock_guard<std::mutex> lock(configMutex);
                for (auto& [typeName, config] : configs) {
                    config.storage->clear();
                    auto objects = Unity::Object::FindObjectsOfType<Unity::CComponent>(typeName.c_str());

                    if (objects) {
                        for (int i = 0; i < objects->m_uMaxLength; i++) {
                            if (auto component = objects->operator[](i)) {
                                if (auto gameObject = component->GetGameObject()) {
                                    config.storage->push_back(gameObject);
                                    if (config.process) {
                                        config.process(gameObject);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            std::this_thread::sleep_for(std::chrono::milliseconds(1000));
        }
    }

    void StopCaching() {
        running.store(false);
    }

private:
    std::unordered_map<std::string, CacheConfig> configs;
    std::mutex configMutex;
    std::atomic<bool> running;
};

extern CacheManager cacheManager;
