# optimisto_infra
## Домашнее задание № 3 (Знакомство с облачной инфраструктурой. Yandex.Cloud)
### VPC
Подключение к someinternalhost в одну команду
```bash
ssh -i ~/.ssh/appuser -A -J appuser@62.84.117.136 someinternalhost
```

Подключение к someinternalhost по алиасу (ssh someinternalhost)
На рабочей машине в `~/.ssh/config` необходимо добавить следующее

```
Host someinternalhost
  User appuser
  ProxyCommand ssh -i ~/.ssh/appuser appuser@62.84.117.136 -W %h:%p
```

После этого можно подключаться к someinternalhost с рабочей машины с помощью команды `ssh someinternalhost`

### VPN
bastion_IP = 62.84.117.136

someinternalhost_IP = 10.128.0.7

### Дополнительное задание
Вместо самоподписанного сертификата получен валидный от Lets Encrypt.
Для этого в настройках Pritunl (поле Lets Encrypt Domain) было указан 62.84.117.136.sslip.io.\
sslip.io - это DNS сервер, который при запросе домена по IP адресу возвращает его же, но уже как поддомен *.sslip.io

В достоверности полученного сертификата можно убедиться по адресу https://62.84.117.136.sslip.io/

## Домашнее задание № 4 (Деплой тестового приложения)

### Дополнительное задание
testapp_IP = 62.84.118.83

testapp_port = 9292

Для выполнения задания передал метадату в формате [cloud-init](https://cloud-init.io/)

```
yc compute instance create \
 --name reddit-app \
 --hostname reddit-app \
 --memory=4 \
 --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-1604-lts,size=10GB \
 --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
 --metadata-from-file user-data=cloud-config.yml \
 --metadata serial-port-enable=1
```

## Домашнее задание № 5 (Сборка образов VM при помощи Packer)

### Параметризирование шаблона
Для деплоя приложения был создан шаблон `ubuntu16.json`. Часть параметров вынесена в `variables.json` (в репозитарий попадёт `variables.json.example` - пример конфига).

Параметры передаются Packer'у через аргумент `--var-file`, так что командная строка для создания образа выглядит так
`packer build --var-file=variables.json ubuntu16.json`

Во время работы столкнулся с такой проблемой - `install_ruby.sh`, вызываемый первым провижнером, при попытке выполнить команду `apt update` возвращал сообщение об ошибке

```
# ==> yandex: E: Could not get lock /var/lib/dpkg/lock-frontend - open (11: Resource temporarily unavailable)
# ==> yandex: E: Unable to acquire the dpkg frontend lock (/var/lib/dpkg/lock-frontend), is another process using it?
```

~~Проблему решил добавлением параметра `max_retries` в провижнер. Выставил значение 5, но обычно срабатывает на 2й раз.~~
~~Причина проблемы неясна, но по симптомам похоже на [это](https://github.com/actions/virtual-environments/issues/1120)~~

__UPD:__ Параметр пришлось убрать, т.к. Packer из автопроверки не знает про такой параметр

### Дополнительное задание № 1 (Построение baked образа)
В качестве основы для создания baked образа был использован `ubuntu16.json` из основного задания.
К нему было добавлено 3 провижнера:
1. Для клонирования исходного репозитория и настройки окружения (bundler)
2. Для копирования в образ systemd unit файла `reddit.service`
3. Установки `reddit.service` в systemd

Кроме того был написан `reddit.service` (на основе рекомендаций из репозитария [puma](https://github.com/puma/puma/blob/master/docs/systemd.md)).

### Дополнительное задание № 2 (Автоматизация создания ВМ)
Создан скрипт для автоматического деплоймента - `config-scripts/create-reddit-vm.sh`.
Для удобства продублирую его содержимое прямо здесь

```
IMAGE_ID=fd8tj09s0n3jrq7hb13i # fake

yc compute instance create \
 --name reddit-full \
 --hostname reddit-full \
 --memory=2 \
 --create-boot-disk image-id=$IMAGE_ID \
 --network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
 --metadata serial-port-enable=1
```

## Домашнее задание № 6 (Практика IaC с использованием Terraform)

Создана конфигурация для развёртывания приложения с помощью Terraform.

Часть значений вынесена в переменные (пример `terraform.tfvars.example`)

Файлы конфигурации были отформатированы с помощью `terraform fmt` (как вариант улучшения: повесить pre-commit hook).

В качестве небольшого костыля пришлось добавить `sleep 20` перед вызовом `apt` в `deploy.sh`

### Дополнительное задание № 1 (Добавление балансировщика)

Конфигурация балансировщика описана в `lb.tf`, также добавлен вывод IP адрес балансировщика - `external_ip_address_lb`.

Количество инстансов бэкэнда задаётся переменной `var.backends_count` со значением по умолчанию 1.

## Домашнее задание № 7 (Принципы организации инфраструктурного кода и работа над инфраструктурой в команде на примере Terraform)

### Основное задание
Созданы 2 модуля Terraform - `db` и `app` - для развёртывания приложения и базы данных соответственно.

Также созданы 2 окружения `stage` и `prod`.

Все .tf файлы отформатированы с помощью `terraform fmt`

### Дополнительное задание № 1

Для хранения стейт файла было создано Object Storage хранилище с одним бакетом.

Стейт файлы для stage и prod хранятся под разными именами.

Кроме того, был сконфигурирован S3 backend для Terraform


### Дополнительное задание № 2

Для модуля `db` был добавлен provisioner, который изменяет bindIp для MongoDB (по умолчанию, слушается только localhost)

В модуле `app` был изменён файл puma.service - добавлена следующая строка

```
[Service]
...
Environment="DATABASE_URL=%DATABASE_URL%"
```

Также в модуль `app` был добавлен provisioner remote-exec, который с помощью `sed` заменял `%DATABASE_URL%` на реальный адрес MongoDB в `puma.service`

## Домашнее задание № 8 (Управление конфигурацией. Основные DevOps инструменты. Знакомство с Ansible)

### Основное задание

> Теперь выполните ansible app -m command -a 'rm -rf ~/reddit' и проверьте еще раз выполнение плейбука. Что изменилось и почему? Добавьте информацию в README.md.

До выполнения команды `rm` - `appserver                  : ok=2    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0`

После выполенения команды  - `appserver                  : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0`

Как видно, поменялось значение `changed`, указывающее на количество тасок, которые изменили что-то на хосте.

До выполнения `rm` репозиторий уже существовал, поэтому изменений на хосте не произошло.

### Дополнительное задание № 1

Для динамического inventory был написан скрипт `dynamic_inventory.py`. Скрипт на основе вывода команды `terraform show | python -m json.tool` (в репозитарий залит пример вывода команды) формирует список инвентори. При этом IP адреса из выходных переменных, содержащие инфикс `db`/`app`, попадают в соответствующую группу хостов. Как вариант, можно было делать такую логику на основе labels.

Требования к скрипту взяты из [документации Ansible](https://docs.ansible.com/ansible/2.5/dev_guide/developing_inventory.html#script-conventions).

Путь до скрипта указан в `ansible.cfg`

Подхватывание динамического инвентори проверил запустив Ansible с расширенным логированием `ansible -vvvv app -m ping`

В выводе команды присутствует следующая строка

`Parsed /mnt/c/Projects/otus/optimisto_infra/ansible/dynamic_inventory.py inventory source with script plugin`

## Домашнее задание № 9 (Деплой и управление конфигурацией с Ansible)

### Основное задание

Пройдены все шаги основного домашнего задания. В качестве самостоятельной работы было сделано:

1. Написан плейбук для деплоя приложения - `deploy.yml`
2. Написаны плейбуки `packer_app.yml` и `packer_db.yml`
3. Произведена замена bash скриптом на вызов провижнера ansible в конфигурации образов Packer, сами образы пересозданы.

### Дополнительное задание

В качестве динамического inventory для Яндекс.Облака был выбран плагин `yc_compute.py` из PR https://github.com/ansible-collections/community.general/pull/772 (с небольшими изменениями). Имя плагина было переименовано с `community.general.yc_compute` на просто `yc_compute` - иначе ansible грузил коллекцию `community.general`, не находил там нужного плагина и завершался с ошибкой.

Было сделано следующее:
1. Файл `yc_compute.py` был сохранен в директорию `ansible/plugins/inventory`.
2. В `ansible.cfg` было добавлено

```
[defaults]
inventory = inventory.yc.yml
...
inventory_plugins=./plugins/inventory

[inventory]
enable_plugins = yc_compute
```
3. Командой `ansible-doc -t inventory yc_compute` проверено наличие плагина (открылась документация)
4. Создан файл `inventory.yc.yml` с описанием конфигурации плагина
5. Установлен Yandex.Cloud SDK (`python3 -m pip install yandexcloud`)
6. Переразвёрнута инфраструктура через Terraform (после была сделана ручная замена значения переменной `db_host`)
7. Выполнена проверка корректного разбиения хостов по группам (`ansible-inventory --graph`)
8. Запущен плейбук `ansible-playbook site.yml`

Результат: по IP адресу приложения (app) открывается приложения Monolith.

### Бонус

Добавил в `.pre-commit-config.yaml` хук `ansible-lint`

## Домашнее задание № 10 (Ansible: работа с ролями и окружениями)

### Основное задание

Пройдены все шаги основного домашнего задания. В качестве самостоятельной работы было сделано:

> Добавьте в конфигурацию Terraform открытие 80 порта для инстанса приложения
> Добавьте вызов роли jdauphant.nginx в плейбук app.yml
> Примените плейбук site.yml для окружения stage и проверьте, что приложение теперь доступно на 80 порту

Дополнительных действий по открытию порта 80 не потребовалось. Приложение доступно как по :9292, так и по :80

### Дополнительное задание №1 (Работа с динамическим инвентори)

В предыдущем домашнем задании доп. задание с динамическим инветори было сделано.

В нынешнем задании `inventory.yc.yml` был скопирован в `environments/(stage|prod)`

При запуске плейбука требуется только указать нужный инвентори файл (`-i`).

### Дополнительное задание №1 (Настройка Github Actions)

Были написаны несколько конфигураций GitHub Action (в директории `.github/workflows`):
- `packer_validate.yml` - для проверки конфигураций Packer
- `ansible_lint.yml` - для проверки Ansible плейбуков
- `terraform_validate.yml` - для проверки Terraform конфигураций (terraform validate и tflint)
- в README.md добавлены бэйджи

В конфигурациях Terraform пришлось заккоментировать `backend.tf` - иначе пришлось бы указывать реальные креды для доступа в бакету с шаренным состоянием. Как вариант: можно удалять эти файлы перед проверкой - в этом случае будет использоваться локальный tfstate.

[![Run Ansible Lint](https://github.com/Otus-DevOps-2021-08/optimisto_infra/actions/workflows/ansible_lint.yml/badge.svg)](https://github.com/Otus-DevOps-2021-08/optimisto_infra/actions/workflows/ansible_lint.yml)

[![Run Packer templates validation](https://github.com/Otus-DevOps-2021-08/optimisto_infra/actions/workflows/packer_validate.yml/badge.svg)](https://github.com/Otus-DevOps-2021-08/optimisto_infra/actions/workflows/packer_validate.yml)

[![Run Terraform configs validation](https://github.com/Otus-DevOps-2021-08/optimisto_infra/actions/workflows/terraform_validate.yml/badge.svg)](https://github.com/Otus-DevOps-2021-08/optimisto_infra/actions/workflows/terraform_validate.yml)

[![Run tests for OTUS homework](https://github.com/Otus-DevOps-2021-08/optimisto_infra/actions/workflows/run-tests.yml/badge.svg)](https://github.com/Otus-DevOps-2021-08/optimisto_infra/actions/workflows/run-tests.yml)
