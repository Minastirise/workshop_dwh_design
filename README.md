# workshop_dwh_design
 Проектирование DWH

## Для старта работы выполните следующие действия
- Из терминала перейдите в папку  
./postgres  
  
- Выполните команду  
docker-compose up  
  
- Дождитесь следующего сообщения:  
LOG:  database system is ready to accept connections  
  

- Зайтите в DBeaver, подключитесь к БД со следующими реквизитами:  
Хост: localhost  
Порт: 5430  
База данных: test  
Пользователь: postgres  
Пароль: postgres  
  
- Проверьте, что данные в базу dev_stg загрузились успешно (должно быть 186):  
select count(*) from dev_stg.dns_2022  
  
## Для завершения работы в терминале выполнить следующую команду из нового терминала из папки ./postgres
docker-compose down --remove-orphans --volumes
