https://wiki.archlinux.org/title/PostgreSQL
# Install
```
sudo pacman -S postgresql postgresql-docs
```

# Create data
```
sudo su - postgres -c "initdb --locale en_US.UTF-8 -D /var/lib/postgres/data"
```
```
systemctl start postgresql.service 
systemctl enable postgresql.service 
```
## user
### switch user
```
su postgres
```

### add user
```
sudo useradd -m -U -r -d /var/lib/postgres -s /bin/bash postgres
```

In to postges
```
CREATE USER myuser WITH PASSWORD 'mypassword';
CREATE DATABASE mydatabase OWNER myuser;
```

Give permisions
```
GRANT ALL PRIVILEGES ON DATABASE mydatabase TO myuser;
```
### Настройка аутентификации (опционально)

Если вы хотите изменить метод аутентификации, отредактируйте файл `pg_hba.conf`, который находится в каталоге данных PostgreSQL (обычно `/var/lib/postgres/data`). Например, чтобы разрешить подключение по паролю для всех пользователей, добавьте строку:

Copy

host    all             all             127.0.0.1/32            md5

После внесения изменений перезапустите службу PostgreSQL:

bash

Copy

sudo systemctl restart postgresql

Теперь у вас должен быть настроенный пользователь `postgres`, а также ваш пользователь с правами доступа к базе данных.
Connect to db
```
psql -U myuser -d mydatabase
```
## go to terminal
Clear terminal
```
sudo -u postgres psql
```

User :
```
psql -U myuser -d mydatabase
```
*myuser* - user
*mydatabase* - database