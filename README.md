# 08-ansible-04-role

**Установка и запуск**:
1. Развернуть хосты на Yandex Cloud, прописать корректные IP в [inventory/prod.yml](./ansible/inventory/prod.yml)
2. Подтягиваем зависимости `ansible-galaxy install -r requirements.yml -p roles`
3. Запускаем playbook `ansible-playbook -i inventory/prod.yml site.yml --diff`

## Описание Playbook

### Play для установки Clickhouse
* Теперь состоит только из запуска роли [clickhouse](https://github.com/AlexeySetevoi/ansible-clickhouse)
* Можно указать конкретную версию, с помощью строковой переменной `clickhouse_version`, значение по умолчанию - 'latest'

### Play для установки Vector
* Теперь состоит только из запуска роли [vector](https://github.com/Roma-EDU/vector-role)
* Можно указать конкретную версию, с помощью строковой переменной `vector_version`, значение по умолчанию - '0.21.1'

### Play для установки Lighthouse
* Для работы встроенной команды `ansible.builtin.git` в pre_tasks устанавливаем git
* С помощью локальной роли [nginx](./ansible/roles/nginx) устанавливаем веб-сервер nginx (локальная роль, так как пришлось в нескольких местах исправить [исходную роль](https://github.com/nginxinc/ansible-role-nginx), чтобы не запускать весь play под sudo)
* И собственно запуск роли [lighthouse](https://github.com/Roma-EDU/lighthouse-role), который раскатывает нужное нам приложение
