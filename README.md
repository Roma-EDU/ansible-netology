# 08-ansible-02-playbook

Подробное описание выполнения по шагам [8.2. Работа с Playbook](https://github.com/Roma-EDU/devops-netology/tree/master/mnt-homeworks/08-ansible-02-playbook)

## Описание Playbook

### Play для установки Clickhouse
- name: Install Clickhouse
  hosts: clickhouse
  handlers:
    - name: Start clickhouse service
      become: true
      ansible.builtin.service:
        name: clickhouse-server
        state: restarted
  tasks:
    - block:
        - name: Install Clickhouse | Download distrib noarch
          ansible.builtin.get_url:
            url: "https://packages.clickhouse.com/rpm/stable/{{ item }}-{{ clickhouse_version }}.noarch.rpm"
            dest: "./{{ item }}-{{ clickhouse_version }}.rpm"
            mode: 0644
          with_items: "{{ clickhouse_packages_noarch }}"
        - name: Install Clickhouse | Download distrib x86_64
          ansible.builtin.get_url:
            url: "https://packages.clickhouse.com/rpm/stable/{{ item }}-{{ clickhouse_version }}.x86_64.rpm"
            dest: "./{{ item }}-{{ clickhouse_version }}.rpm"
            mode: 0644
          with_items: "{{ clickhouse_packages_x86_64 }}"
    - name: Install Clickhouse | Install packages
      become: true
      ansible.builtin.yum:
        name:
          - clickhouse-common-static-{{ clickhouse_version }}.rpm
          - clickhouse-client-{{ clickhouse_version }}.rpm
          - clickhouse-server-{{ clickhouse_version }}.rpm
      notify: Start clickhouse service
  post_tasks:
    - block:
      - name: Install Clickhouse | Wait for clickhouse to be running
        ansible.builtin.service_facts:
        register: actual_services_state
        until: actual_services_state.ansible_facts.services['clickhouse-server.service'].state == 'running'
        retries: 10
        delay: 500
    - name: Install Clickhouse | Create database
      ansible.builtin.command: "clickhouse-client -q 'create database logs;'"
      register: create_db
      failed_when: create_db.rc != 0 and create_db.rc !=82
      changed_when: create_db.rc == 0
### Play для установки Vector
* `name: Install Vector` - название Play
* `hosts: vector` - хосты, на которых будет выполнено (см. inventory/prod.yml)
* `tasks:` - список задач, которые нужны для успешного выполнения Play
* Первый шаг - скачать rpm `name: Install Vector | Download distrib`
  * `ansible.builtin.get_url:` - с помощью встроенной команды `get_url`
    * `url: "https://packages.timber.io/vector/{{ vector_version }}/vector-{{ vector_version }}-1.x86_64.rpm"` - скачиваем по этому url файл (`https://packages.timber.io/vector/0.21.1/vector-0.21.1-1.x86_64.rpm`)
    * `dest: "./vector-{{ vector_version }}.rpm"` - кладём его в по пути (в итоге в текущей директории должен появиться файл `vector-0.21.1.rpm`) и 
    * `mode: 0644` - задаём ему права доступа 0644 (текущему пользователю чтение и запись, остальным только чтение)
* Второй шаг - установить rpm `name: Install Vector | Install packages`
  * `become: true` - повышаем привилегии до root
  * `ansible.builtin.yum:` - устанавливаем скачанный на предыдущем шаге пакет с помощью модуля yum
    * `name: "vector-{{ vector_version }}.rpm"` - файл `vector-0.21.1.rpm`
        
## Переменные 

Переменные, значения которых со временем можно обновить:
| Название переменной | Значение по умолчанию | Тип | Описание |
| --- | --- | --- | --- |
| `clickhouse_version` | `22.3.3.44` | Строка | Версия ClickHouse |
| `vector_version` | `0.21.1` | Строка | Версия Vector |
