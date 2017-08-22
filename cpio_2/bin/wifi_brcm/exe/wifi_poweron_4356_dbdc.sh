#!/system/bin/busybox sh

echo wifi_on 3000000000 > /sys/power/wake_lock
echo 1 > /proc/sys/vm/drop_caches
echo "ready to load dhd FW and NVram"
#��ȡ��Ʒ���ƣ�����Ʒ������Ϊ�������ݸ�WiFi�����ű�
PRODUCTNAME=$(cat /proc/productname)
/system/bin/lsmod | grep dhd
if [ $? -ne 0 ]
then 
    echo "first power on second load FW dhd and NVram"
    /system/bin/ecall wifi_power_off_4356
    /system/bin/ecall wifi_power_on_4356
    /system/bin/sleep 1s
if [ -z $PRODUCTNAME ]
then
    echo "productname is NULL"
    /system/bin/insmod /system/bin/wifi_brcm/driver/dhd.ko firmware_path=/system/bin/wifi_brcm/firmware/rtecdc_dbdc.bin.trx nvram_path=/system/bin/wifi_brcm/nv/bcm4356.nv
else
    echo "product is $PRODUCTNAME"
    /system/bin/insmod /system/bin/wifi_brcm/driver/dhd.ko firmware_path=/system/bin/wifi_brcm/firmware/rtecdc_dbdc.bin.trx nvram_path=/system/bin/wifi_brcm/nv/bcm4356_$PRODUCTNAME.nv dhd_dpc_prio=1
fi
else
    echo "dhd is valid"
fi

    ifconfig WiFi0 up
if [ $PRODUCTNAME = "SB03" ]
then
    /system/bin/ecall wifi_set_product_id 1
fi

exit 0