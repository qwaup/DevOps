# SSH
Базовые настройки в '/etc/ssh/sshd_config':
```
PermitRootLogin no  # Отключаем вход для root
PasswordAuthentication no  # Отключаем вход по паролю 
AuthenticationMethods publickey  # Указываем допустимый метод входа
ClientAliveInterval 600  # Устанавливаем таймаут бездействия в секундах (например, 600) 
MaxAuthTries 3  # Устанавливаем число попыток авторизации (например, 3) 
Protocol 2  # Protocol ssh2
AllowUsers admin bastion_user  # Ограничиваем конкретных пользователей можно с соурсами sidorov@5.6.7.8.
LoginGraceTime 1m  # Ограничиваем что то
ListenAddress 192.168.1.100
\# Устанавливаем в конфиге SSH-сервера следующий порядок поддерживаемых алгоритмов ключей хоста:
HostKey /etc/ssh/ssh_host_ed25519_key
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ecdsa_key
\# Определяем алгоритмы и типы ключей для клиентов: 
KexAlgorithms 
curve25519-sha256@libssh.org,ecdh-sha2-nistp521,ecdh-sha2-nistp384,ecdh-sha2-nistp256,diffie-hellman-group-exchange-sha256
Ciphers 
chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs 
hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,umac-128-etm@openssh.com,hmac-sha2-512,hmac-sha2-256,umac-128@openssh.com 
\# Запрещаем вообще весь форвардинг конфиге SSH-сервера, кроме tcp:
AllowAgentForwarding yes
AllowStreamLocalForwarding no
X11Forwarding no
LogLevel VERBOSE  # Без комментариев
```

# Fail2Ban
```
[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 1h
findtime = 10m
ignoreip = 127.0.0.1/8 192.168.1.0/24
```

# Firewall
Закрываемся фаерволом. Я просто привык к firewalld. Но лучше на nft.
Можно вести вайтлист с адресами людей которые должны иметь доступ(динамика через днс как вариант)
``` bash
# Установить целевую зону на DROP для запрета всех входящих соединений
firewall-cmd --zone=public --set-target=DROP
# Разрешить доступ к порту 22 (SSH)
firewall-cmd --zone=public --add-port=22/tcp --permanent
# Применить изменения
firewall-cmd --reload
# Привязать интерфейс ens192 к зоне public (если еще не привязан)
firewall-cmd --zone=public --change-interface=ens192
```

# Auditd (Не работал, рекомендации взяты из интернета)
```
# Мониторинг изменений в критических файлах
-w /etc/ssh/sshd_config -p wa -k sshd_config
-w /etc/passwd -p wa -k user_changes
-w /etc/sudoers -p wa -k privilege_escalation

# Мониторинг использования sudo
-a always,exit -F arch=b64 -S execve -F path=/usr/bin/sudo -k sudo_use
```

# Рекомендации
## Меньше значит лучше
Выполняем следующую команду и оцениваем, какие сервисы точно не пригодятся.

```systemctl list-units --type=service --state=running```
## Собираем логи на внешний ресурс
Loki или Elasticsearch или хотя бы syslog. На них же можем настроить алерты на определенные сообщения.

# Актуализируем ключи при разворачивании из образов при копировании \ работе с шаблонами вм
``` bash
rm /etc/ssh/ssh_host_*
ssh-keygen -t rsa -b 4096 -f /etc/ssh/ssh_host_rsa_key -N ""
ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -N ""
```

# Стратегии защиты
- SSH-ключи (RSA 4096-bit или Ed25519) + парольная фраза + регулярное обновление
- Разрешать подключения только с доверенных IP через firewall
- Обновления безопасности
- Регулярный аудит прав пользователей
- Мониторинг подозрительной активности
- Двухфакторная аутентификация
- Prometheus+node_exporter для метрик
- Создание пользователей на бастион сервере без оболочки ```useradd -s /sbin/nologin ivanov``` без явной на то необходимости
- Настройка хостов в сети на прием подключении только с бастиона(без фанатизма)
