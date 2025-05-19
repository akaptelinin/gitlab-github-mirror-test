param (
    [string]$OUTFILE = "dev_conflict.txt"
)

$UNIQUE_ID = [guid]::NewGuid().ToString()
$TIMESTAMP = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$HASH = (git rev-parse HEAD).Trim()

@'
##############################################
#        ВНИМАНИЕ: ВЕТКА DEV ПЕРЕСОЗДАНА       #
##############################################
'@ | Out-File -Encoding utf8 -FilePath $OUTFILE

"# Уникальный ID ветки: $UNIQUE_ID" | Out-File -Encoding utf8 -FilePath $OUTFILE -Append
"# Дата создания: $TIMESTAMP" | Out-File -Encoding utf8 -FilePath $OUTFILE -Append
"# Хэш коммита: $HASH" | Out-File -Encoding utf8 -FilePath $OUTFILE -Append

@'
##############################################

'@ | Out-File -Encoding utf8 -FilePath $OUTFILE -Append

for ($i = 1; $i -le 500; $i++) {
    "Инструкция #$i: Обновите локальную ветку: git fetch origin && git checkout dev && git pull" | Out-File -Encoding utf8 -FilePath $OUTFILE -Append
}

for ($i = 1; $i -le 500; $i++) {
    $RANDOM_HASH = -join ((65..90) + (97..122) + (48..57) | Get-Random -Count 32 | % {[char]$_})
    "Конфликтная строка #$i: $RANDOM_HASH" | Out-File -Encoding utf8 -FilePath $OUTFILE -Append
}

@'
##############################################
# Если вы видите этот файл — ваша локальная ветка устарела!
# Пожалуйста, обновите её перед пушем!
# Мы верим в вас! Код — это жизнь! :)
##############################################
'@ | Out-File -Encoding utf8 -FilePath $OUTFILE -Append
