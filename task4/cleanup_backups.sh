#!/usr/bin/env bash
set -u

shopt -s nullglob

if [ $# -lt 1 ]; then
    echo "Ошибка: Недостаточно аргументов." >&2
    echo "Использование: $0 <путь_к_папке_бэкапов>" >&2
    echo "Пример: $0 /var/backups/projects" >&2
    exit 1
fi

BACKUP_DIR="$1"
KEEP_COUNT=5

if [ ! -d "$BACKUP_DIR" ]; then
    echo "Ошибка: Директория '$BACKUP_DIR' не существует." >&2
    exit 1
fi

echo "=== Запуск очистки всех проектов в: $BACKUP_DIR ==="

projects_processed=0

for project_dir in "$BACKUP_DIR"/*/; do
    ((projects_processed++))

    (
        project_name=$(basename "$project_dir")
        echo ""
        echo "--- Проект: $project_name ---"

        cd "$project_dir" || { echo "Не удалось зайти в $project_dir, пропускаю."; exit 1; }

        mapfile -t TO_DELETE < <(find . -maxdepth 1 -type f -printf '%T@ %p\n' | sort -rn | tail -n +$((KEEP_COUNT + 1)) | cut -d' ' -f2-)

        if [ ${#TO_DELETE[@]} -eq 0 ]; then
            echo "В папке $project_name $KEEP_COUNT или меньше файлов, удалять нечего."
            exit 0
        fi

        echo "Найдено старых бэкапов на удаление: ${#TO_DELETE[@]}"
        for file in "${TO_DELETE[@]}"; do
            clean_name=$(basename "$file")
            rm -f "$file"
            echo "  Удалено: $clean_name"
        done
    )
done

if [ "$projects_processed" -eq 0 ]; then
    echo ""
    echo "Инфо: В директории '$BACKUP_DIR' не найдено ни одной папки с проектами."
fi

echo ""
echo "Очистка завершена"