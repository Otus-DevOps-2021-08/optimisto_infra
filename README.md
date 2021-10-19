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
