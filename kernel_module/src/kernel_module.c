#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/ioport.h>
#include <asm/errno.h>
#include <asm/io.h>

MODULE_INFO(intree, "Y");
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Jakub Kadlubowski");
MODULE_DESCRIPTION("Simple kernel module for SYKOM lecture");
MODULE_VERSION("0.01");

#define SYKT_GPIO_BASE_ADDR (0x00100000)
#define SYKT_GPIO_SIZE (0x8000)
#define SYKT_EXIT (0x3333)
#define SYKT_EXIT_CODE (0x7F)
#define SYKT_GPIO_ADDR_SPACE (0x00100000)
#define A1_ADDR (SYKT_GPIO_ADDR_SPACE + 0x1D8)
#define A2_ADDR (SYKT_GPIO_ADDR_SPACE + 0x1E0)
#define W_ADDR (SYKT_GPIO_ADDR_SPACE + 0x1E8)
#define L_ADDR (SYKT_GPIO_ADDR_SPACE + 0x1F0)
#define B_ADDR (SYKT_GPIO_ADDR_SPACE + 0x1F8)
#define u32 unsigned long

struct kobject *sykt;
void __iomem *baseptr;
void __iomem *a1;
void __iomem *a2;
void __iomem *w;
void __iomem *b;
void __iomem *l;

// Wspólne funkcje
static ssize_t kj_read(struct kobject *kobj, struct kobj_attribute *attr, char *buf, u32 *reg)
{
    return sprintf(buf, "%lx \n", readl(reg));
}

static ssize_t kj_write(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count, u32 *reg)
{
    u32 x;
    if (sscanf(buf, "%lx", &x) <= 0)
    {
        return 0;
    }
    writel(x, reg);
    return count;
}

// -----------------------

static ssize_t kjaa1_read(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
    return kj_read(kobj, attr, buf, a1);
}

static ssize_t kjaa1_write(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{
    return kj_write(kobj, attr, buf, count, a1);
}

static ssize_t kjaa2_read(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
    return kj_read(kobj, attr, buf, a2);
}

static ssize_t kjaa2_write(struct kobject *kobj, struct kobj_attribute *attr, const char *buf, size_t count)
{
    return kj_write(kobj, attr, buf, count, a2);
}

static ssize_t kjaw_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
    return kj_read(kobj, attr, buf, w);
}

static ssize_t kjab_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
    return kj_read(kobj, attr, buf, b);
}

static ssize_t kjal_show(struct kobject *kobj, struct kobj_attribute *attr, char *buf)
{
    return kj_read(kobj, attr, buf, l);
}

// ------------------------

struct kobj_attribute kjaa1_attr = __ATTR(kjaa1, 0660, kjaa1_read, kjaa1_write);
struct kobj_attribute kjaa2_attr = __ATTR(kjaa2, 0660, kjaa2_read, kjaa2_write);
struct kobj_attribute kjaw_attr = __ATTR_RO(kjaw);
struct kobj_attribute kjab_attr = __ATTR_RO(kjab);
struct kobj_attribute kjal_attr = __ATTR_RO(kjal);

int my_init_module(void)
{
    printk(KERN_INFO "Initialize my sykom module.\n");

    baseptr = ioremap(SYKT_GPIO_BASE_ADDR, SYKT_GPIO_SIZE);

    a1 = ioremap(A1_ADDR, SYKT_GPIO_SIZE);
    a2 = ioremap(A2_ADDR, SYKT_GPIO_SIZE);
    w = ioremap(W_ADDR, SYKT_GPIO_SIZE);
    l = ioremap(L_ADDR, SYKT_GPIO_SIZE);
    b = ioremap(B_ADDR, SYKT_GPIO_SIZE);

    sykt = kobject_create_and_add("sykt", kernel_kobj);

    int file_not_open;

    file_not_open = sysfs_create_file(sykt, &kjaa1_attr.attr);
    if (file_not_open)
    {
        printk(KERN_INFO "Failed to create new file(A1) %d\n", file_not_open);

        return 1;
    }

    file_not_open = sysfs_create_file(sykt, &kjaa2_attr.attr);
    if (file_not_open)
    {
        printk(KERN_INFO "Failed to create new file(A2) %d\n", file_not_open);

        return 1;
    }

    file_not_open = sysfs_create_file(sykt, &kjaw_attr.attr);
    if (file_not_open)
    {
        printk(KERN_INFO "Failed to create new file(W) %d\n", file_not_open);

        return 1;
    }

    file_not_open = sysfs_create_file(sykt, &kjab_attr.attr);
    if (file_not_open)
    {
        printk(KERN_INFO "Failed to create new file(B) %d\n", file_not_open);

        return 1;
    }

    file_not_open = sysfs_create_file(sykt, &kjal_attr.attr);
    if (file_not_open)
    {
        printk(KERN_INFO "Failed to create new file(L) %d\n", file_not_open);

        return 1;
    }

    /*sysfs_create_file(sykt, &kjaa1_attr.attr);
    sysfs_create_file(sykt, &kjaa2_attr.attr);
    sysfs_create_file(sykt, &kjaw_attr.attr);
    sysfs_create_file(sykt, &kjab_attr.attr);
    sysfs_create_file(sykt, &kjal_attr.attr);*/

    return 0;
}

void my_cleanup_module(void)
{
    printk(KERN_INFO "Clean up my sykom module.\n");
    writel(SYKT_EXIT | ((SYKT_EXIT_CODE) << 16), baseptr);
    iounmap(baseptr);
    iounmap(a1);
    iounmap(a2);
    iounmap(w);
    iounmap(l);
    iounmap(b);

    kobject_put(sykt);
}

module_init(my_init_module)
    module_exit(my_cleanup_module)