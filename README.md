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
bastion_IP = 62.84.117.136\
someinternalhost_IP = 10.128.0.7

### Дополнительное задание
Вместо самоподписанного сертификата получен валидный от Lets Encrypt.
Для этого в настройках Pritunl (поле Lets Encrypt Domain) было указан 62.84.117.136.sslip.io.\
sslip.io - это DNS сервер, который при запросе домена по IP адресу возвращает его же, но уже как поддомен *.sslip.io

В достоверности полученного сертификата можно убедиться по адресу https://62.84.117.136.sslip.io/
