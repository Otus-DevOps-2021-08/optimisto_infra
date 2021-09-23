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
