```
sudo mkdir -p /mnt/ramdisk
```

```
sudo mount -t tmpfs -o size=1G tmpfs /mnt/ramdisk
```
Если нужен динамический обьем можно не указывать size

## fstab
```
tmpfs /mnt/ramdisk tmpfs defaults,size=1G 0 0
```