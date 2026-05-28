#!/usr/bin/env python3
import os
import sys
import subprocess
import time

HOSTS_FILE = "/opt/orchestrator/hosts.txt"
SOURCE_FILE = "/opt/orchestrator/payload.txt"
REMOTE_DEST = "/home/app/storage/payload.txt"  
SSH_USER = "root" 
SSH_TIMEOUT = 5

def load_hosts():
    """Читает файл инвентаря и возвращает список серверов [{ip, last_time}]"""
    hosts = []
    if not os.path.exists(HOSTS_FILE):
        print(f"Ошибка: Файл инвентаря {HOSTS_FILE} не найден!", file=sys.stderr)
        sys.exit(1)
        
    with open(HOSTS_FILE, "r") as f:
        for line in f:
            line = line.strip()
            if line and not line.startswith("#"):
                ip, last_time = line.split(":")
                hosts.append({"ip": ip, "last_time": int(last_time)})
    return hosts

def save_hosts(hosts):
    with open(HOSTS_FILE, "w") as f:
        for host in hosts:
            f.write(f"{host['ip']}:{host['last_time']}\n")

def check_ssh(ip):
    cmd = [
        "ssh", "-o", f"ConnectTimeout={SSH_TIMEOUT}", 
        "-o", "StrictHostKeyChecking=no", 
        f"{SSH_USER}@{ip}", "true"
    ]
    result = subprocess.run(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return result.returncode == 0

def upload_file_rsync(ip):
    rsync_cmd = [
        "rsync", "-az", "--delay-updates", "--mkpath",  # <-- Добавит автоматическое создание папок
        "-e", f"ssh -o ConnectTimeout={SSH_TIMEOUT} -o StrictHostKeyChecking=no",
        SOURCE_FILE, f"{SSH_USER}@{ip}:{REMOTE_DEST}"
    ]
    result = subprocess.run(rsync_cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    return result.returncode == 0

def main():
    if not os.path.exists(SOURCE_FILE):
        print(f"Ошибка: Исходный файл {SOURCE_FILE} не существует!", file=sys.stderr)
        sys.exit(1)

    hosts = load_hosts()
    
    hosts.sort(key=lambda x: x["last_time"])
    
    file_delivered = False
    
    for host in hosts:
        ip = host["ip"]
        print(f"Проверяю доступность сервера {ip}...")
        
        if check_ssh(ip):
            print(f"Сервер {ip} доступен. Начинаю отправку через rsync...")
            if upload_file_rsync(ip):
                print(f"Успех! Файл атомарно доставлен на {ip}.")
                host["last_time"] = int(time.time())
                file_delivered = True
                break
            else:
                print(f"Сбой rsync при передаче на сервер {ip}. Пробую следующий хост...")
        else:
            print(f"Сервер {ip} не отвечает по SSH. Пропускаю...")
            
    if file_delivered:
        save_hosts(hosts)
    else:
        print("Критическая ошибка: Ни один сервер из списка не доступен!", file=sys.stderr)
        sys.exit(2)

if __name__ == "__main__":
    main()