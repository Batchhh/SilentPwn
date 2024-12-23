#pragma once

#include <iostream>
#include <string>

namespace IL2CPP
{
    namespace Helper
    {
        Unity::CComponent *GetMonoBehaviour()
        {
            Unity::il2cppArray<Unity::CGameObject *> *m_Objects = Unity::Object::FindObjectsOfType<Unity::CGameObject>(UNITY_GAMEOBJECT_CLASS);
            for (uintptr_t u = 0U; m_Objects->m_uMaxLength > u; ++u)
            {
                Unity::CGameObject *m_Object = m_Objects->operator[](static_cast<unsigned int>(u));
                if (!m_Object)
                    continue;

                Unity::CComponent *m_MonoBehaviour = m_Object->GetComponentByIndex(UNITY_MONOBEHAVIOUR_CLASS);
                if (m_MonoBehaviour)
                    return m_MonoBehaviour;
            }

            return nullptr;
        }

        template <typename Ret, typename... Args>
        Ret InvokeStaticMethod(const std::string &className, const std::string &methodName, Args... args)
        {
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return Ret();
            }

            uint64_t methodPointer = IL2CPP::Class::Utils::GetMethodPointerRVA(il2cppClass, methodName.c_str(), sizeof...(args));
            if (!methodPointer)
            {
                std::cerr << "Method " << methodName << " not found in class " << className << ".\n";
                return Ret();
            }

            return reinterpret_cast<Ret (*)(Args...)>(methodPointer)(args...);
        }

        template <typename T>
        T GetStaticFieldValue(const std::string &className, const std::string &fieldName)
        {
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return T();
            }

            void *value = IL2CPP::Class::Utils::GetStaticField(il2cppClass, fieldName.c_str());
            if (!value)
            {
                std::cerr << "Field " << fieldName << " not found in class " << className << ".\n";
                return T();
            }

            return *reinterpret_cast<T *>(value);
        }

        template <typename T>
        void SetStaticFieldValue(const std::string &className, const std::string &fieldName, const T &value)
        {
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return;
            }

            IL2CPP::Class::Utils::SetStaticField(il2cppClass, fieldName.c_str(), (void *)&value);
        }

        template <typename T>
        T GetPropertyValue(Unity::CGameObject *obj, const std::string &className, const std::string &propertyName)
        {
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return T();
            }

            auto instance = obj->GetComponent(className.c_str());
            if (!instance)
            {
                std::cerr << "Failed to get instance of class " << className << ".\n";
                return T();
            }

            return reinterpret_cast<T (*)(void *)>(IL2CPP::Class::Utils::GetMethodPointer(il2cppClass, ("get_" + propertyName).c_str()))(instance);
        }

        template <typename T>
        void SetPropertyValue(Unity::CGameObject *obj, const std::string &className, const std::string &propertyName, const T &value)
        {
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return;
            }

            auto instance = obj->GetComponent(className.c_str());
            if (!instance)
            {
                std::cerr << "Failed to get instance of class " << className << ".\n";
                return;
            }

            reinterpret_cast<void (*)(void *, T)>(IL2CPP::Class::Utils::GetMethodPointer(il2cppClass, ("set_" + propertyName).c_str()))(instance, value);
        }

        Unity::CGameObject *CloneGameObject(Unity::CGameObject *obj, const Unity::Vector3 &position)
        {
            auto il2cppClass = IL2CPP::Class::Find("UnityEngine.Object");
            if (!il2cppClass)
            {
                std::cerr << "Class UnityEngine.Object not found.\n";
                return nullptr;
            }

            void *instantiateMethod = IL2CPP::Class::Utils::GetMethodPointer(il2cppClass, "Instantiate", 1);
            if (!instantiateMethod)
            {
                std::cerr << "Method Instantiate not found in class UnityEngine.Object.\n";
                return nullptr;
            }

            auto clonedObj = reinterpret_cast<Unity::CGameObject *(*)(void *)>(instantiateMethod)(obj);
            if (!clonedObj)
            {
                std::cerr << "Failed to clone object.\n";
                return nullptr;
            }

            auto transform = clonedObj->GetTransform();
            transform->SetPosition(position);

            return clonedObj;
        }

        Unity::CGameObject *FindGameObjectByName(const std::string &name)
        {
            auto gameObject = Unity::GameObject::Find(name.c_str());
            if (!gameObject)
            {
                std::cerr << "GameObject " << name << " not found.\n";
            }
            return gameObject;
        }

        std::vector<Unity::CGameObject *> FindGameObjectsWithTag(const std::string &tag)
        {
            auto gameObjectsArray = Unity::GameObject::FindWithTag(tag.c_str());
            std::vector<Unity::CGameObject *> gameObjects;
            if (!gameObjectsArray)
            {
                std::cerr << "No GameObjects found with tag " << tag << ".\n";
                return gameObjects;
            }
            for (size_t i = 0; i < gameObjectsArray->m_uMaxLength; ++i)
            {
                gameObjects.push_back(gameObjectsArray->operator[](i));
            }
            return gameObjects;
        }

        template <typename T>
        T *GetComponent(Unity::CGameObject *obj, const std::string &componentName)
        {
            auto component = obj->GetComponent(componentName.c_str());
            if (!component)
            {
                std::cerr << "Component " << componentName << " not found in GameObject.\n";
                return nullptr;
            }
            return reinterpret_cast<T *>(component);
        }

        template <typename T>
        std::vector<T *> GetComponents(Unity::CGameObject *obj, const std::string &componentName)
        {
            auto componentsArray = obj->GetComponents(componentName.c_str());
            std::vector<T *> components;
            if (!componentsArray)
            {
                std::cerr << "No components found with name " << componentName << " in GameObject.\n";
                return components;
            }
            for (size_t i = 0; i < componentsArray->m_uMaxLength; ++i)
            {
                components.push_back(reinterpret_cast<T *>(componentsArray->operator[](i)));
            }
            return components;
        }

        void SetGameObjectPosition(Unity::CGameObject *obj, const Unity::Vector3 &position)
        {
            auto transform = obj->GetTransform();
            transform->SetPosition(position);
        }

        Unity::Vector3 GetGameObjectPosition(Unity::CGameObject *obj)
        {
            auto transform = obj->GetTransform();
            return transform->GetPosition();
        }

        void SetGameObjectRotation(Unity::CGameObject *obj, const Unity::Quaternion &rotation)
        {
            auto transform = obj->GetTransform();
            transform->SetRotation(rotation);
        }

        Unity::Quaternion GetGameObjectRotation(Unity::CGameObject *obj)
        {
            auto transform = obj->GetTransform();
            return transform->GetRotation();
        }

        template <typename Ret, typename... Args>
        Ret CreateInstanceAndInvoke(const std::string &className, const std::string &ctorName, const std::string &methodName, Args... ctorArgs)
        {
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return Ret();
            }

            void *ctorPointer = IL2CPP::Class::Utils::GetMethodPointer(il2cppClass, ctorName.c_str(), sizeof...(ctorArgs));
            if (!ctorPointer)
            {
                std::cerr << "Constructor " << ctorName << " not found in class " << className << ".\n";
                return Ret();
            }

            auto instance = reinterpret_cast<Unity::il2cppObject *(*)(Args...)>(ctorPointer)(ctorArgs...);
            if (!instance)
            {
                std::cerr << "Failed to create instance of class " << className << ".\n";
                return Ret();
            }

            void *methodPointer = IL2CPP::Class::Utils::GetMethodPointer(il2cppClass, methodName.c_str(), 0);
            if (!methodPointer)
            {
                std::cerr << "Method " << methodName << " not found in class " << className << ".\n";
                return Ret();
            }

            return reinterpret_cast<Ret (*)(void *)>(methodPointer)(instance);
        }

        void PrintInstanceFields(Unity::il2cppObject *instance, const std::string &className)
        {
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return;
            }

            std::vector<Unity::il2cppFieldInfo *> fields;
            IL2CPP::Class::FetchFields(il2cppClass, &fields);
            for (const auto &field : fields)
            {
                std::cout << field->m_pName << ": " << reinterpret_cast<void *>(reinterpret_cast<uintptr_t>(instance) + field->m_iOffset) << std::endl;
            }
        }

        std::vector<Unity::CGameObject *> FindAllInstancesByClass(const std::string &className)
        {
            std::vector<Unity::CGameObject *> instances;
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return instances;
            }

            auto allObjects = Unity::Object::FindObjectsOfType<Unity::CGameObject>("UnityEngine.GameObject");
            if (!allObjects)
            {
                std::cerr << "No GameObjects found.\n";
                return instances;
            }

            for (size_t i = 0; i < allObjects->m_uMaxLength; ++i)
            {
                auto gameObject = allObjects->operator[](i);
                if (gameObject->GetComponent(className.c_str()))
                {
                    instances.push_back(gameObject);
                }
            }
            return instances;
        }

        template <typename Ret, typename... Args>
        Ret InvokeMethodByRVA(uintptr_t rva, void *instance, Args... args)
        {
            auto methodPointer = reinterpret_cast<Ret(UNITY_CALLING_CONVENTION)(void *, Args...)>(rva);
            return methodPointer(instance, args...);
        }

        template <typename Ret, typename... Args>
        void InvokeMethodOnAllInstancesByRVA(const std::string &className, uintptr_t rva, Args... args)
        {
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return;
            }

            auto allObjects = Unity::Object::FindObjectsOfType<Unity::CGameObject>("UnityEngine.GameObject");
            if (!allObjects)
            {
                std::cerr << "No GameObjects found.\n";
                return;
            }

            for (size_t i = 0; i < allObjects->m_uMaxLength; ++i)
            {
                auto gameObject = allObjects->operator[](i);
                auto component = gameObject->GetComponent(className.c_str());
                if (component)
                {
                    std::cout << "Invoking method on instance: " << gameObject->GetName()->ToString() << "\n";
                    InvokeMethodByRVA<Ret, Args...>(rva, component, args...);
                }
            }
        }

        template <typename Ret, typename... Args>
        using MethodDelegate = Ret (*)(void *, Args...);

        template <typename Ret, typename... Args>
        Ret InvokeMethodByDelegate(Unity::CGameObject *obj, const std::string &className, const std::string &methodName, Args... args)
        {
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return Ret();
            }

            void *methodPointer = IL2CPP::Class::Utils::GetMethodPointer(il2cppClass, methodName.c_str(), sizeof...(args));
            if (!methodPointer)
            {
                std::cerr << "Method " << methodName << " not found in class " << className << ".\n";
                return Ret();
            }

            auto instance = obj->GetComponent(className.c_str());
            if (!instance)
            {
                std::cerr << "Failed to get instance of class " << className << ".\n";
                return Ret();
            }

            MethodDelegate<Ret, Args...> method = reinterpret_cast<MethodDelegate<Ret, Args...>>(methodPointer);
            return method(instance, args...);
        }

        template <typename Ret, typename... Args>
        Ret InvokeMethodOnComponent(Unity::CGameObject *obj, const std::string &componentName, const std::string &methodName, Args... args)
        {
            auto component = obj->GetComponent(componentName.c_str());
            if (!component)
            {
                std::cerr << "Component " << componentName << " not found in GameObject.\n";
                return Ret();
            }

            auto il2cppClass = IL2CPP::Class::Find(componentName.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << componentName << " not found.\n";
                return Ret();
            }

            void *methodPointer = IL2CPP::Class::Utils::GetMethodPointer(il2cppClass, methodName.c_str(), sizeof...(args));
            if (!methodPointer)
            {
                std::cerr << "Method " << methodName << " not found in class " << componentName << ".\n";
                return Ret();
            }

            return reinterpret_cast<Ret (*)(void *, Args...)>(methodPointer)(component, args...);
        }

        void CountAndPrintInstances(const std::string &className)
        {
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return;
            }

            auto allObjects = Unity::Object::FindObjectsOfType<Unity::CGameObject>(className.c_str());
            if (!allObjects)
            {
                std::cout << "No instances of class " << className << " found.\n";
                return;
            }

            size_t count = allObjects->m_uMaxLength;
            std::cout << "Number of instances of class " << className << ": " << count << "\n";

            for (size_t i = 0; i < count; ++i)
            {
                auto gameObject = allObjects->operator[](i);
                std::cout << "Instance " << i + 1 << ": " << gameObject->GetName()->ToString() << "\n";
            }
        }

        Unity::CGameObject *CreateInstance(const std::string &className)
        {
            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return nullptr;
            }

            void *createInstanceMethod = IL2CPP::Class::Utils::GetMethodPointer(il2cppClass, "Instantiate", 1);
            if (!createInstanceMethod)
            {
                std::cerr << "Instantiate method not found in class " << className << ".\n";
                return nullptr;
            }

            auto instance = reinterpret_cast<Unity::CGameObject *(UNITY_CALLING_CONVENTION)(void *)>(createInstanceMethod)(nullptr);
            if (!instance)
            {
                std::cerr << "Failed to create instance of class " << className << ".\n";
                return nullptr;
            }

            std::cout << "Instance of class " << className << " created.\n";
            return instance;
        }

        template <typename Ret, typename... Args>
        void InvokeMethodOnTaggedGameObjects(const std::string &tag, const std::string &className, const std::string &methodName, Args... args)
        {
            auto gameObjectsArray = Unity::GameObject::FindWithTag(tag.c_str());
            if (!gameObjectsArray)
            {
                std::cerr << "No GameObjects found with tag " << tag << ".\n";
                return;
            }

            auto il2cppClass = IL2CPP::Class::Find(className.c_str());
            if (!il2cppClass)
            {
                std::cerr << "Class " << className << " not found.\n";
                return;
            }

            void *methodPointer = IL2CPP::Class::Utils::GetMethodPointer(il2cppClass, methodName.c_str());
            if (!methodPointer)
            {
                std::cerr << "Method " << methodName << " not found in class " << className << ".\n";
                return;
            }

            for (size_t i = 0; i < gameObjectsArray->m_uMaxLength; ++i)
            {
                auto gameObject = gameObjectsArray->operator[](i);
                if (gameObject)
                {
                    auto component = gameObject->GetComponent(className.c_str());
                    if (component)
                    {
                        reinterpret_cast<Ret (*)(void *, Args...)>(methodPointer)(component, args...);
                    }
                }
            }
        }

        void DestroyGameObjectsByTag(const std::string &tag)
        {
            auto gameObjectsArray = Unity::GameObject::FindWithTag(tag.c_str());
            if (!gameObjectsArray)
            {
                std::cerr << "No GameObjects found with tag " << tag << ".\n";
                return;
            }

            for (size_t i = 0; i < gameObjectsArray->m_uMaxLength; ++i)
            {
                auto gameObject = gameObjectsArray->operator[](i);
                gameObject->Destroy();
                std::cout << "Destroyed GameObject with tag " << tag << ": " << gameObject->GetName()->ToString() << "\n";
            }
        }
    }
}
