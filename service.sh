#!/system/bin/sh
MODDIR=${0%/*}

while [ "$(getprop sys.boot_completed)" != "1" ]; do
    sleep 20
done

# Workqueue tweaks
if [ -f /sys/module/workqueue/parameters/power_efficient ]; then
    chmod 0644 /sys/module/workqueue/parameters/power_efficient
    echo N > /sys/module/workqueue/parameters/power_efficient
fi

if [ -f /sys/module/workqueue/parameters/disable_numa ]; then
    chmod 0644 /sys/module/workqueue/parameters/disable_numa
    echo N > /sys/module/workqueue/parameters/disable_numa
fi

# Disable IO stats
for queue in /sys/block/*/queue; do
    if [ -f "$queue/iostats" ]; then
        echo 0 > "$queue/iostats"
    fi
done

# Disable thermal zone
for zone in /sys/class/thermal/thermal_zone*/mode; do
    echo disabled > "$zone" 2>/dev/null
done

stop thermal_core 2>/dev/null
stop thermald 2>/dev/null

su -lp 2000 -c "cmd notification post -S bigtext -t 'Rozen Thermal' Xenaaa 'Thermal successfully applied'"
