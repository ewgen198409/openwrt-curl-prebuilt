#!/bin/sh

# Цветовые коды
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' 
BOLD='\033[1m'

# Иконки
CHECK_MARK="${GREEN}✔${NC}"
CROSS_MARK="${RED}✘${NC}"
INFO_ICON="${BLUE}ℹ${NC}"

# 1. Баннер
clear
echo -e "${CYAN}${BOLD}"
echo "  _    _ _______ _______ _____ ____  "
echo " | |  | |__   __|__   __|  __ |___ \ "
echo " | |__| |  | |     | |  | |__) |__) |"
echo " |  __  |  | |     | |  |  ___|__ <  "
echo " | |  | |  | |     | |  | |    ___) |"
echo " |_|  |_|  |_|     |_|  |_|   |____/ "
echo -e "      OpenWrt HTTP3 Support Enabler${NC}"
echo "------------------------------------------"

# 2. Подготовка и обновление
echo -e "${INFO_ICON} Обновление списков пакетов (opkg update)..."
opkg update > /dev/null 2>&1

# Определение архитектуры
ARCH=$(opkg print-architecture | awk 'BEGIN{priority=0} {if($3>priority){priority=$3; arch=$2}} END{print arch}')

if [ -z "$ARCH" ]; then
    echo -e "${CROSS_MARK} ${RED}Ошибка: Не удалось определить архитектуру!${NC}"
    exit 1
fi

echo -e "${INFO_ICON} Целевая архитектура: ${BOLD}$ARCH${NC}"

# Поиск файлов: устанавливаем все пакеты для целевой архитектуры
VALID_FILES=""
TOTAL=0
for file in ./*_"${ARCH}".ipk; do
    [ -e "$file" ] || continue
    file="${file#./}"
    VALID_FILES="$VALID_FILES $file"
    TOTAL=$((TOTAL + 1))
done

if [ "$TOTAL" -eq 0 ]; then
    echo -e "${CROSS_MARK} ${RED}Ошибка: .ipk файлы для $ARCH не найдены в папке!${NC}"
    exit 1
fi

# 3. Процесс установки
CURRENT=0
SUCCESS_COUNT=0

draw_progress() {
    local width=30
    local percent=$(( ($1 * 100) / $2 ))
    local filled=$(( ($1 * width) / $2 ))
    local empty=$(( width - filled ))
    printf "\r${YELLOW}Установка: ${NC}${BLUE}[${NC}"
    printf "%${filled}s" | tr ' ' '#'
    printf "%${empty}s" | tr ' ' '-'
    printf "${BLUE}]${NC} %d%% (%d/%d)" "$percent" "$1" "$2"
}

echo -e "\n${BOLD}Начинаю инсталляцию пакетов...${NC}"

for pkg in $VALID_FILES; do
    CURRENT=$((CURRENT + 1))
    draw_progress "$CURRENT" "$TOTAL"
    
    if opkg install "$pkg" --force-reinstall --force-overwrite > /dev/null 2>&1; then
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    fi
done

echo -e "\n"

# 4. Финальная проверка и тест HTTP3
echo -e "${BOLD}Проверка работоспособности...${NC}"
sleep 1

# Проверяем наличие поддержки h3 в curl
if command -v curl > /dev/null 2>&1; then
    H3_SUPPORT=$(curl --version 2>/dev/null | grep -i "http/3\|h3")
    
    if [ -n "$H3_SUPPORT" ]; then
        echo -e "------------------------------------------"
        echo -e "${CHECK_MARK} ${GREEN}${BOLD}УСТАНОВКА ЗАВЕРШЕНА УСПЕШНО!${NC}"
        echo -e "${INFO_ICON} Версия curl:"
        curl --version | head -1
        echo -e "${INFO_ICON} Поддержка: ${CYAN}HTTP/3 (QUIC)${NC}"
        echo -e "------------------------------------------"
        echo -e "${MAGENTA}${BOLD}Приятного использования нового стека!${NC}\n"
        exit 0
    fi
fi

echo -e "------------------------------------------"
echo -e "${CHECK_MARK} Пакеты установлены ($SUCCESS_COUNT/$TOTAL)"
echo -e "${INFO_ICON} Выполните ${BOLD}curl --version${NC} для проверки HTTP/3"
echo -e "------------------------------------------\n"
