# Окружение
2 инстанса пг в контейнерах NODE{1,2}, первый инитится скл скриптом для наполнения "какими то" данными.

Хранение бекапов вопреки ТЗ вынесено с NODE2 в отдельный вольюм монтирующийся к дженкинсу, причины тривиальны - проще в тестировании + бекапы не должны храниться рядом с субд
# Проверка работопособности
Все дальнейшие действия производятся из текущей дериктории!
В данном разделе представлен docker compose на котором можно проверить пайплайн на деле
- ``` docker compose -f Docker-compose.yml build jenkins ```
- Запуск докер компоуз

  ``` docker compose -f Docker-compose.yml up -d ```

После этого будет доступен дженкинс http://localhost:8080/job/TestDevOps с заранее проброшеной джобой, при её первоначальном запуске произведется бекап NODE1 и восстановление NODE2.

При последующих запусках первоначальный шаг восстановления бекапа упадёт с ошибкой (из за отсуствия флага -c в команде восстановления), зато запустится резервный шаг восстановления предыдущего бекапа

Важно. Пайплайн собран на скорую руку, т.к концепция небольшого тестового предполагает пару часов на решение, тут же можно закопаться очень и очень сильно, есть куда разгруляться.

# INFO
После проверки тестового и остановки компоуза ``` docker compose -f Docker-compose.yml down``` очистка мусора на локалхосте производится командами
- ``` docker system prune -a ```
- ``` docker volume prune -a ```
