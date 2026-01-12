#!/bin/bash
export GDK_BACKEND=x11
export GDK_DISABLE_WARNINGS=1

source "$(dirname "$0")/core.sh"

while true; do
    # DÜZELTME: --separator="" eklendi.
    # Böylece çıktı "Servisleri Listele|" yerine "Servisleri Listele" olacak.
    ACTION=$(yad --list \
        --title="PARDUS Control Center - Servis Yönetimi" \
        --width=500 --height=300 \
        --column="İşlem" \
        "Servisleri Listele" \
        "Servis Durumu Göster" \
        "Servis Başlat" \
        "Servis Durdur" \
        "Servis Yeniden Başlat" \
        "Servis Sağlık Kontrolü" \
        "Çıkış" \
        --print-column=1 \
        --separator="" \
        --no-multi)

    RET=$?
    [ $RET -ne 0 ] && exit   # Cancel veya pencere kapandı

    case "$ACTION" in
        "Servisleri Listele")
            list_services | yad --text-info \
                --title="Servis Listesi" \
                --width=800 --height=500 \
                --fontname="monospace"
            ;;
        "Servis Durumu Göster")
            SERVICE=$(yad --entry --text="Servis adını girin:")
            [ -z "$SERVICE" ] && continue
            service_status "$SERVICE" | yad --text-info \
                --title="$SERVICE Durumu" \
                --width=600 --height=400 \
                --fontname="monospace"
            ;;
        "Servis Başlat")
            SERVICE=$(yad --entry --text="Başlatılacak servis:")
            [ -z "$SERVICE" ] && continue
            start_service "$SERVICE" | yad --text-info --timeout=3 --title="İşlem Sonucu" --width=400 --height=200
            ;;
        "Servis Durdur")
            SERVICE=$(yad --entry --text="Durdurulacak servis:")
            [ -z "$SERVICE" ] && continue
            stop_service "$SERVICE" | yad --text-info --timeout=3 --title="İşlem Sonucu" --width=400 --height=200
            ;;
        "Servis Yeniden Başlat")
            SERVICE=$(yad --entry --text="Yeniden başlatılacak servis:")
            [ -z "$SERVICE" ] && continue
            restart_service "$SERVICE" | yad --text-info --timeout=3 --title="İşlem Sonucu" --width=400 --height=200
            ;;
        "Servis Sağlık Kontrolü")
            SERVICE=$(yad --entry --text="Sağlığı kontrol edilecek servis:")
            [ -z "$SERVICE" ] && continue
            # Fonksiyon çıktısını yad'a pipe ediyoruz
            service_health_check "$SERVICE" | yad --text-info \
                --title="$SERVICE - Sağlık Durumu" \
                --width=600 --height=400 \
                --fontname="monospace"
            ;;
        "Çıkış")
            exit
            ;;
    esac
done
            ;;
    esac
done
