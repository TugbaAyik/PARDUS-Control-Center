#!/bin/bash

# --- Mevcut Fonksiyonlar ---
list_services() {
    local output
    output=$(systemctl list-units --type=service --no-pager 2>&1)
    echo "$output"
}

service_status() {
    systemctl status "$1" --no-pager
}

start_service() {
    sudo systemctl start "$1"
}

stop_service() {
    sudo systemctl stop "$1"
}

restart_service() {
    sudo systemctl restart "$1"
}

service_health_check() {
    SERVICE="$1"
    # Servis aktif mi?
    if systemctl is-active --quiet "$SERVICE"; then
        STATUS="active"
    else
        STATUS="inactive"
    fi
    
    # Loglardaki hataları say
    ERRORS=$(journalctl -u "$SERVICE" -p err -n 20 --no-pager 2>/dev/null | wc -l)

    echo "Servis: $SERVICE"
    echo "Durum : $STATUS"
    echo "Son 20 kayıttaki ERROR sayısı: $ERRORS"
    echo "----------------------------------------"

    if [[ "$STATUS" != "active" || "$ERRORS" -gt 3 ]]; then
        echo "⚠️ UYARI: Servis sağlığı sorunlu olabilir."
    else
        echo "✅ Servis sağlıklı görünüyor."
    fi
}

# --- TUI İçin Eklenen Eksik Fonksiyonlar ---

# TUI 'list_services_colored' arıyor, normal listeye yönlendirelim
list_services_colored() {
    list_services
}

# TUI 'service_logs' arıyor
service_logs() {
    # Son 50 satır logu göster
    journalctl -u "$1" -n 50 --no-pager
}

# TUI 'system_info' arıyor
system_info() {
    echo "=== SİSTEM BİLGİSİ ==="
    echo ""
    echo "Hostname : $(hostname)"
    echo "Kernel   : $(uname -r)"
    echo "Uptime   : $(uptime -p)"
    echo ""
    echo "--- Bellek Kullanımı ---"
    free -h
    echo ""
    echo "--- Disk Kullanımı ---"
    df -h / | awk 'NR==1 || NR==2 {print $0}'
}

# TUI 'add_cron_job' arıyor
add_cron_job() {
    JOB="$1"
    # Mevcut crontab'ı al, yeni işi ekle ve kaydet
    (crontab -l 2>/dev/null; echo "$JOB") | crontab -
}
