# **Virsh Command Cheat Sheet**

### **1. Managing Virtual Machines**
#### **Start, Stop, and Restart VMs**
```bash
virsh start <vm-name>           # Start a VM
virsh shutdown <vm-name>        # Gracefully shutdown a VM
virsh reboot <vm-name>          # Restart a VM
virsh destroy <vm-name>         # Force shutdown a VM (hard power off)
```

#### **Pause and Resume VMs**
```bash
virsh suspend <vm-name>         # Pause (freeze) a VM
virsh resume <vm-name>          # Resume a paused VM
```

#### **List VMs**
```bash
virsh list                      # List running VMs
virsh list --all                # List all VMs (including stopped)
```

#### **Delete a VM**
```bash
virsh undefine <vm-name>        # Remove a VM from libvirt (keeps disk)
virsh undefine --nvram <vm-name> # Remove with NVRAM (UEFI VMs)
```

### **2. Managing VM Snapshots**
```bash
virsh snapshot-list <vm-name>   # List snapshots of a VM
virsh snapshot-create-as <vm-name> <snapshot-name> --disk-only --atomic  # Create a live disk-only snapshot
virsh snapshot-revert <vm-name> <snapshot-name>  # Revert to a snapshot
virsh snapshot-delete <vm-name> <snapshot-name>  # Delete a snapshot
```

### **3. Managing VM Disks**
```bash
virsh vol-list --pool default   # List all disks in the "default" storage pool
virsh attach-disk <vm-name> /path/to/disk.img vdb --live --persistent  # Attach a disk to a running VM
virsh detach-disk <vm-name> vdb --live --persistent  # Remove a disk from a running VM
```

### **4. Managing VM Network**
```bash
virsh net-list                  # List available virtual networks
virsh domiflist <vm-name>        # List network interfaces of a VM
virsh domifaddr <vm-name>        # Show assigned IP addresses of a VM
virsh attach-interface <vm-name> bridge br0 --live --persistent  # Attach a network interface
virsh detach-interface <vm-name> bridge br0 --live --persistent  # Detach a network interface
```

### **5. Managing VM Resources**
```bash
virsh setvcpus <vm-name> <num> --config --live  # Change CPU count
virsh setmem <vm-name> 4G --config --live       # Set memory allocation
```

### **6. Managing VM Configurations**
```bash
virsh dumpxml <vm-name>          # View VM configuration in XML
virsh edit <vm-name>             # Edit VM configuration using a text editor
```

### **7. Cloning and Creating VMs**
```bash
virt-clone --original <source-vm> --name <new-vm> --file /path/to/new-disk.img  # Clone a VM
virt-install --name <vm-name> --ram 2048 --vcpus 2 --disk path=/path/to/disk.img,size=20 --os-variant centos7 --network bridge=br0 --graphics none --console pty,target_type=serial --cdrom /path/to/iso  # Create a new VM
```

### **8. Monitoring VMs**
```bash
virsh dominfo <vm-name>          # Get detailed info about a VM
virsh cpu-stats <vm-name>        # CPU usage statistics
virsh dommemstat <vm-name>       # Memory usage statistics
virsh domblkstat <vm-name> vda   # Disk I/O statistics
virsh domifstat <vm-name> vnet0  # Network statistics
```

### **9. Managing Storage Pools**
```bash
virsh pool-list                 # List available storage pools
virsh pool-start default        # Start a storage pool
virsh pool-autostart default    # Enable auto-start for a storage pool
virsh pool-destroy default      # Stop a storage pool
virsh pool-undefine default     # Remove a storage pool
```

### **10. Managing Network Pools**
```bash
virsh net-list --all            # List all virtual networks
virsh net-start default         # Start a virtual network
virsh net-destroy default       # Stop a virtual network
virsh net-undefine default      # Remove a virtual network
