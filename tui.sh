#!/bin/bash
source "$(dirname "$0")/core.sh"

while true; do
    CHOICE=$(whiptail --title "PARDUS Control Center (TUI)" \
        --menu "Bir işlem seçin (Yön tuşları ile gezinin):" 20 70 8 \
        "1" "Servis Durum Tablosu" \
        "2" "Servis Loglarını Göster" \
        "3" "Cron Job Ekle" \
        "4" "Sistem Bilgisi" \
        "5" "Servis Sağlık Kontrolü" \
        "6" "Çıkış" \
        3>&1 1>&2 2>&3)

    [ $? -ne 0 ] && exit

    case "$CHOICE" in
        "1")
            # Çıktı üretiyoruz
            list_services_colored > /tmp/services.txt
            # --textbox otomatik scroll özelliğine sahiptir
            whiptail --title "Servis Durumları (Ok Tuşları ile İnin)" \
                --textbox /tmp/services.txt 40 100
        ;;
        "2")
            SERVICE=$(whiptail --inputbox "Servis adını girin (örn: ssh.service)" 8 60 \
                3>&1 1>&2 2>&3)
            [ -z "$SERVICE" ] && continue

            service_logs "$SERVICE" > /tmp/logs.txt
            
            # Eğer log boşsa kullanıcıyı uyar, değilse göster
            if [ -s /tmp/logs.txt ]; then
                whiptail --title "$SERVICE Logları (PageUp/Down Kullanın)" \
                    --textbox /tmp/logs.txt 40 100
            else
                whiptail --msgbox "Bu servis için log bulunamadı veya servis adı hatalı." 8 50
            fi
        ;;
        "3")
            CRON=$(whiptail --inputbox \
                "Cron formatı girin:\n* * * * * /komut" \
                10 70 3>&1 1>&2 2>&3)
            [ -z "$CRON" ] && continue

            add_cron_job "$CRON"
            whiptail --msgbox "Cron job eklendi." 8 40
        ;;
        "4")
            system_info > /tmp/sysinfo.txt
            whiptail --title "Sistem Bilgisi" \
                --textbox /tmp/sysinfo.txt 30 80
        ;;
        "5")
           SERVICE=$(whiptail --inputbox \
           "Sağlığı kontrol edilecek servis adı:\n(örn: ssh.service)" \
           10 60 3>&1 1>&2 2>&3)
           [ -z "$SERVICE" ] && continue

           service_health_check "$SERVICE" > /tmp/health.txt

           whiptail --title "Servis Sağlık Durumu" \
           --textbox /tmp/health.txt 20 70
        ;;

        "6")
            exit
        ;;
    esac
done
done
