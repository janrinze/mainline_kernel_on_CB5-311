# mainline_kernel_on_CB5-311
Repositiory for kernel configs and patches for the Acer CB5-311 chromebook.

kernel config for kernel 6.12.8 and patch for eDP panel.

The script ```crosscompilei.sh``` will:
  - checkout kernel sources 6.12.8 in the directory linux-stable
  - patch those kernel sources
  - configure the kernel sources with supplied config
  - compile the kernel
  - combine kernel, dtb, cmdline into a file kernel.bin

Copy kernel.bin to the kernel partition.
Copy the modules from the directory ```modules/lib/modules/``` to the target OS.

The kernel cmdline expects it is installed on a USB attached disk.
That disk should have a cgpt format with 2 partitions:
  - KERN_A ```ChromeOS Kernel``` of at least 32MB
  - ROOT_A root partition for OS

