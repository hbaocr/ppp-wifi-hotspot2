#include <linux/module.h>
#include <linux/vermagic.h>
#include <linux/compiler.h>

MODULE_INFO(vermagic, VERMAGIC_STRING);
MODULE_INFO(name, KBUILD_MODNAME);

__visible struct module __this_module
__attribute__((section(".gnu.linkonce.this_module"))) = {
	.name = KBUILD_MODNAME,
	.init = init_module,
#ifdef CONFIG_MODULE_UNLOAD
	.exit = cleanup_module,
#endif
	.arch = MODULE_ARCH_INIT,
};

#ifdef CONFIG_RETPOLINE
MODULE_INFO(retpoline, "Y");
#endif

static const struct modversion_info ____versions[]
__used
__attribute__((section("__versions"))) = {
	{ 0xaf381eb0, __VMLINUX_SYMBOL_STR(module_layout) },
	{ 0xab3d033d, __VMLINUX_SYMBOL_STR(remove_proc_entry) },
	{ 0x96aa2f7e, __VMLINUX_SYMBOL_STR(proc_create) },
	{ 0x20c55ae0, __VMLINUX_SYMBOL_STR(sscanf) },
	{ 0x362ef408, __VMLINUX_SYMBOL_STR(_copy_from_user) },
	{ 0xbac3fdc9, __VMLINUX_SYMBOL_STR(put_tty_driver) },
	{ 0x4d5ffc2c, __VMLINUX_SYMBOL_STR(tty_register_driver) },
	{ 0x8cf31c1e, __VMLINUX_SYMBOL_STR(tty_port_link_device) },
	{ 0x693fda1a, __VMLINUX_SYMBOL_STR(tty_port_init) },
	{ 0x895cb871, __VMLINUX_SYMBOL_STR(tty_set_operations) },
	{ 0x67b27ec1, __VMLINUX_SYMBOL_STR(tty_std_termios) },
	{ 0x15a943ca, __VMLINUX_SYMBOL_STR(__tty_alloc_driver) },
	{ 0xfb578fc5, __VMLINUX_SYMBOL_STR(memset) },
	{ 0xcbd4898c, __VMLINUX_SYMBOL_STR(fortify_panic) },
	{ 0xad27f361, __VMLINUX_SYMBOL_STR(__warn_printk) },
	{ 0x88db9f48, __VMLINUX_SYMBOL_STR(__check_object_size) },
	{ 0xa916b694, __VMLINUX_SYMBOL_STR(strnlen) },
	{ 0x91715312, __VMLINUX_SYMBOL_STR(sprintf) },
	{ 0x37a0cba, __VMLINUX_SYMBOL_STR(kfree) },
	{ 0x2347482a, __VMLINUX_SYMBOL_STR(tty_unregister_driver) },
	{ 0xb543d689, __VMLINUX_SYMBOL_STR(tty_unregister_device) },
	{ 0xc507d65b, __VMLINUX_SYMBOL_STR(tty_port_destroy) },
	{ 0xdb7305a1, __VMLINUX_SYMBOL_STR(__stack_chk_fail) },
	{ 0xf9696887, __VMLINUX_SYMBOL_STR(remove_wait_queue) },
	{ 0x1000e51, __VMLINUX_SYMBOL_STR(schedule) },
	{ 0x11f13787, __VMLINUX_SYMBOL_STR(add_wait_queue) },
	{ 0xaad8c7d6, __VMLINUX_SYMBOL_STR(default_wake_function) },
	{ 0x9b65a65f, __VMLINUX_SYMBOL_STR(current_task) },
	{ 0xb44ad4b3, __VMLINUX_SYMBOL_STR(_copy_to_user) },
	{ 0xa47f0e4b, __VMLINUX_SYMBOL_STR(module_put) },
	{ 0x5eac9f0c, __VMLINUX_SYMBOL_STR(try_module_get) },
	{ 0xd7b64983, __VMLINUX_SYMBOL_STR(kmem_cache_alloc_trace) },
	{ 0x59acc80d, __VMLINUX_SYMBOL_STR(kmalloc_caches) },
	{ 0xb445ea6c, __VMLINUX_SYMBOL_STR(tty_flip_buffer_push) },
	{ 0x4e4e8f5e, __VMLINUX_SYMBOL_STR(tty_insert_flip_string_fixed_flag) },
	{ 0x17c8215e, __VMLINUX_SYMBOL_STR(up) },
	{ 0x587c8d3f, __VMLINUX_SYMBOL_STR(down) },
	{ 0x5c3c286e, __VMLINUX_SYMBOL_STR(tty_wakeup) },
	{ 0x27e1a049, __VMLINUX_SYMBOL_STR(printk) },
	{ 0xbdfb6dbb, __VMLINUX_SYMBOL_STR(__fentry__) },
};

static const char __module_depends[]
__used
__attribute__((section(".modinfo"))) =
"depends=";


MODULE_INFO(srcversion, "A6C061F4342940BDE122B44");
