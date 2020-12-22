obj-m := applesmc_t2_kmod.o

all:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules

install:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) modules_install

clean:
	$(MAKE) -C $(KERNEL_DIR) M=$(PWD) clean
