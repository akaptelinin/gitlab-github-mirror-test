param (
    [string]$OUTFILE
)

$UNIQUE_ID = [guid]::NewGuid().ToString()
$TIMESTAMP = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$HASH = (git rev-parse HEAD).Trim()

@"
##############################################
#        ВНИМАНИЕ: ВЕТКА DEV ПЕРЕСОЗДАНА       #
##############################################
# Уникальный ID ветки: $UNIQUE_ID
# Дата создания: $TIMESTAMP
# Хэш коммита: $HASH
##############################################

"@ | Out-File -Encoding utf8 -FilePath $OUTFILE

for ($i = 1; $i -le 500; $i++) {
    "Инструкция #$i: Обновите локальную ветку: git fetch origin && git checkout dev && git pull" | Add-Content -Encoding utf8 -Path $OUTFILE
}

for ($i = 1; $i -le 500; $i++) {
    $RANDOM_HASH = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | % {[char]$_})
    "Конфликтная строка #$i: $RANDOM_HASH" | Add-Content -Encoding utf8 -Path $OUTFILE
}

@"
##############################################
# Если вы видите этот файл — ваша локальная ветка устарела!
# Пожалуйста, обновите её перед пушем!
# Мы верим в вас! Код — это жизнь! :)
##############################################
"@ | Add-Content -Encoding utf8 -Path $OUTFILE
