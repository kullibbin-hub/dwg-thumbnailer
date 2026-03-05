#!/bin/bash
set -e

# 1. Скачивание архива
echo 'Скачиваем NConvert
'
cd /tmp
wget https://download.xnview.com/NConvert-linux64.tgz -O NConvert-linux64.tgz

# 2. Распаковка в /usr/local
#sudo rm -rf /usr/local/NConvert
sudo tar -xzf NConvert-linux64.tgz -C /usr/local
#sudo mv /usr/local/NConvert-linux64 /usr/local/NConvert

# 3. Симлинк в /usr/local/bin
sudo rm -f /usr/local/bin/nconvert
sudo ln -s /usr/local/NConvert/nconvert /usr/local/bin/nconvert

# 4. Скрипт dwg-thumbnail.sh
echo 'Создаем /usr/local/bin/dwg-thumbnail.sh
'
sudo tee /usr/local/bin/dwg-thumbnail.sh >/dev/null <<'EOF'
#!/bin/bash
INPUT="$1"
OUTPUT="$2"
SIZE="$3"

NCONVERT="/usr/local/bin/nconvert"

# Создаём директорию для результата
mkdir -p "$(dirname "$OUTPUT")"

# Создаём временный файл с расширением .dwg
TMP="/tmp/dwgthumb-$$.dwg"
cp "$INPUT" "$TMP"

# Генерация PNG
"$NCONVERT" -quiet -out png -resize "$SIZE" "$SIZE" -o "$OUTPUT" "$TMP"

rm -f "$TMP"
EOF

sudo chmod +x /usr/local/bin/dwg-thumbnail.sh

# 5. Файл dwg.thumbnailer
echo 'Создаем /usr/share/thumbnailers/dwg.thumbnailer
'
sudo tee /usr/share/thumbnailers/dwg.thumbnailer >/dev/null <<'EOF'
[Thumbnailer Entry]
TryExec=/usr/local/bin/dwg-thumbnail.sh
Exec=/usr/local/bin/dwg-thumbnail.sh %i %o %s
MimeType=image/vnd.dwg; image/x-dwg; application/acad;
Flags=NoCopy
EOF

# 6. Очистка кэша миниатюр
echo 'Очистка кэша миниатюр
'
rm -rf ~/.cache/thumbnails/*

echo "Установка завершена. Теперь желательно перезайти в сессию
или перезагрузить компьютер."

