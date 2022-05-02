# 08-ansible-02-playbook

Подробное описание выполнения по шагам [8.2. Работа с Playbook](https://github.com/Roma-EDU/devops-netology/tree/master/mnt-homeworks/08-ansible-02-playbook)

## Описание Playbook

### Play для установки Clickhouse
* `name: Install Clickhouse` - название Play
* `hosts: clickhouse` - хосты, на которых будет выполнено (см. [inventory/prod.yml](./ansible/inventory/prod.yml))
* `handlers:` - обработчик некоторого события, который вызывается из `task` с помощью `notify` и только в том случае, когда таска считается изменённой (статус changed)
  * `name: Start clickhouse service` - название обработчика (по этому имени осуществляется вызов)
  * `become: true` - повышаем привилегии до root
  * `ansible.builtin.service:` - используем модуль `service`
    * `name: clickhouse-server` - название службы
    * `state: restarted` - требуется её перезапуск
* `tasks:` - список задач, которые нужны для успешного выполнения Play
  * `block:` - логический блок задач
  * Первая часть блока - скачиваем дистрибутивы ClickHouse с архитектурой noarch `name: Install Clickhouse | Download distrib noarch`
    * `ansible.builtin.get_url:` - с помощью встроенного модуля `get_url` и подставновки переменных в фигурные скобки из [group_vars/clickhouse/vars.yml](./ansible/group_vars/clickhouse/vars.yml) (т.к. текущий хост - clickhouse)
      * `url: "https://packages.clickhouse.com/rpm/stable/{{ item }}-{{ clickhouse_version }}.noarch.rpm"`
      * `dest: "./{{ item }}-{{ clickhouse_version }}.rpm"`
      * `mode: 0644`
    * `with_items: "{{ clickhouse_packages_noarch }}"` - выполнить по всем элементам, находящимся в списке clickhouse_packages_noarch (т.е. clickhouse-client и clickhouse-server)
  * Вторая часть блока - аналогично скачиваем дистрибутивы ClickHouse с архитектурой x86_64 `name: Install Clickhouse | Download distrib x86_64`
    * `ansible.builtin.get_url:`
      * `url: "https://packages.clickhouse.com/rpm/stable/{{ item }}-{{ clickhouse_version }}.x86_64.rpm"`
      * `dest: "./{{ item }}-{{ clickhouse_version }}.rpm"`
      * `mode: 0644`
    * `with_items: "{{ clickhouse_packages_x86_64 }}"` - выполнить по всем элементам, находящимся в списке clickhouse_packages_noarch (т.е. clickhouse-common-static)
  * Следующия задача - установка трёх скачанных пакетов `name: Install Clickhouse | Install packages`
    * `become: true` - повышаем привилегии до root
    * `ansible.builtin.yum:` - устанавливаем скачанный на предыдущем шаге пакет с помощью модуля yum
      * `name:` - список устанавливаемых пакетов с подстановкой переменных из того же [group_vars/clickhouse/vars.yml](./ansible/group_vars/clickhouse/vars.yml); в принципе можно было сделать и с помощью `with_items` или `loop`
        * `clickhouse-common-static-{{ clickhouse_version }}.rpm` - т.е. clickhouse-common-static-22.3.3.44.rpm
        * `clickhouse-client-{{ clickhouse_version }}.rpm` - т.е. clickhouse-client-22.3.3.44.rpm
        * `clickhouse-server-{{ clickhouse_version }}.rpm` - т.е. clickhouse-server-22.3.3.44.rpm
    * `notify: Start clickhouse service` - если задача будет в состоянии `changed`, то будет вызван `handler` по этому имени
* `post_tasks:` - задачи, которые будут выполнены после всех `tasks`
  * `block:` - блок случайно остался от отладки, когда были дополнительные шаги с просмотром значений переменных (`debug: vars: actual_services_state` и `fail: msg: "fail to wait"`), сейчас он не требуется
  * Единственная задача блока - ожидаем запуска службы `name: Install Clickhouse | Wait for clickhouse to be running`
    * `ansible.builtin.service_facts:` - собираем данные о всех службах с помощью модуля `service_facts`
    * `register: actual_services_state` - записываем результат работы во вспомогательную переменную `actual_services_state`
    * `until: actual_services_state.ansible_facts.services['clickhouse-server.service'].state == 'running'` - выполняем эту задачу до тех пор пока служба 'clickhouse-server.service' (оказалось нужно к названию clickhouse-server дописать .service) не окажется в состоянии 'running'
    * `retries: 10` - максимальное количество повторов
    * `delay: 500` - интервал в мс между повторами
  * Завершающая задача - создание таблицы в базе данных `name: Install Clickhouse | Create database`
    * `ansible.builtin.command: "clickhouse-client -q 'create database logs;'"` - выполняем баш-команду с помощью модуля `command`
    * `register: create_db` - результат запоминаем во вспомогательную переменную `create_db`
    * `failed_when: create_db.rc != 0 and create_db.rc !=82` - если поле rc результата не равно 0 (успешно выполнена) и не равно 82 (таблица уже существует), то считаем что задача завершена с ошибкой
    * `changed_when: create_db.rc == 0` - если результат 0, то задача завершена со статусом `changed`

### Play для установки Vector
* `name: Install Vector` - название Play
* `hosts: vector` - хосты, на которых будет выполнено (см. [inventory/prod.yml](./ansible/inventory/prod.yml))
* `tasks:` - список задач, которые нужны для успешного выполнения Play
* Первый шаг - скачать rpm `name: Install Vector | Download distrib`
  * `ansible.builtin.get_url:` - с помощью встроенного модуля `get_url` и подставновки переменных в фигурные скобки из [group_vars/vector/vars.yml](./ansible/group_vars/vector/vars.yml) (т.к. текущий хост - vector)
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
