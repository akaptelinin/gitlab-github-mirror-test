#!/bin/bash

OUTFILE="$1"
UNIQUE_ID=$(uuidgen)
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
HASH=$(git rev-parse HEAD)

echo "##############################################" > $OUTFILE
echo "#        ВНИМАНИЕ: ВЕТКА DEV ПЕРЕСОЗДАНА       #" >> $OUTFILE
echo "##############################################" >> $OUTFILE
echo "# Уникальный ID ветки: $UNIQUE_ID" >> $OUTFILE
echo "# Дата создания: $TIMESTAMP" >> $OUTFILE
echo "# Хэш коммита: $HASH" >> $OUTFILE
echo "##############################################" >> $OUTFILE
echo "" >> $OUTFILE

for i in $(seq 1 500); do
  echo "Инструкция #$i: Обновите локальную ветку: git fetch origin && git checkout dev && git pull" >> $OUTFILE
done

for i in $(seq 1 500); do
  RANDOM_HASH=$(openssl rand -hex 16)
  echo "Конфликтная строка #$i: $RANDOM_HASH" >> $OUTFILE
done

echo "" >> $OUTFILE
echo "##############################################" >> $OUTFILE
echo "# Если вы видите этот файл — ваша локальная ветка устарела!" >> $OUTFILE
echo "# Пожалуйста, обновите её перед пушем!" >> $OUTFILE
echo "# Мы верим в вас! Код — это жизнь! :)" >> $OUTFILE
echo "##############################################" >> $OUTFILE
