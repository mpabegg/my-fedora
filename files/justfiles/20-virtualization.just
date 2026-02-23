# Virtualization setup commands

# Setup virtualization (libvirt/virt-manager)
[group("virtualization")]
setup-virtualization ACTION="":
    #!/usr/bin/bash
    set -e
    
    red='\033[0;31m'
    green='\033[0;32m'
    bold='\033[1m'
    n='\033[0m'
    
    if [[ $(id -u) -eq 0 ]]; then
      echo "Please do not run this command as root"
      exit 1
    fi
    
    if [ "$(systemctl is-enabled libvirtd.service 2>/dev/null)" == "disabled" ] || ! systemctl is-enabled libvirtd.service &>/dev/null; then
      echo "${bold}libvirtd${n} service is ${red}disabled${n}!"
      echo "${green}Enabling${n} and starting libvirtd"
      sudo systemctl enable --now libvirtd 2> /dev/null || true
    fi
    
    OPTION={{ ACTION }}
    
    if [ "$OPTION" == "help" ]; then
      echo "Usage: just setup-virtualization <option>"
      echo "  virt-on     - Enable Virtualization"
      echo "  virt-off    - Disable Virtualization"
      echo "  group       - Add $USER to libvirt group"
      echo "  vfio-on     - Enable VFIO drivers (for GPU passthrough)"
      echo "  vfio-off    - Disable VFIO drivers"
      exit 0
    elif [ "$OPTION" == "" ]; then
      echo "${bold}Virtualization Setup${n}"
      echo "NOTE: Enabling Virtualization will install virt-manager flatpak"
      PS3="Select option: "
      options=("Enable Virtualization" "Disable Virtualization" "Add $USER to libvirt group" "Enable VFIO drivers" "Disable VFIO drivers" "Quit")
      select opt in "${options[@]}"; do
        case $opt in
          "Enable Virtualization") OPTION="virt-on"; break ;;
          "Disable Virtualization") OPTION="virt-off"; break ;;
          "Add $USER to libvirt group") OPTION="group"; break ;;
          "Enable VFIO drivers") OPTION="vfio-on"; break ;;
          "Disable VFIO drivers") OPTION="vfio-off"; break ;;
          "Quit") exit 0 ;;
          *) echo "Invalid option"; exit 1 ;;
        esac
      done
    fi
    
    if [[ "$OPTION" == "virt-on" ]]; then
      echo "Setting up virtualization..."
      
      if ! flatpak list | grep -q org.virt_manager.virt-manager; then
        echo "Installing virt-manager..."
        flatpak install -y flathub org.virt_manager.virt-manager
      fi
      
      echo "Setting kernel args for KVM..."
      rpm-ostree kargs \
        --append-if-missing="kvm.ignore_msrs=1" \
        --append-if-missing="kvm.report_ignored_msrs=0"
      
      echo "Setting up swtpm..."
      if [ ! -d "/var/lib/swtpm-localca" ]; then
        sudo mkdir /var/lib/swtpm-localca
      fi
      sudo chown tss /var/lib/swtpm-localca 2>/dev/null || true
      
      echo "Restoring SELinux contexts..."
      sudo restorecon -rv /var/lib/libvirt 2>/dev/null || true
      sudo restorecon -rv /var/log/libvirt 2>/dev/null || true
      
      echo "Giving qemu access to read ISO files from $HOME..."
      sudo setfacl -m u:qemu:rx $HOME 2>/dev/null || true
      
      echo "${green}Virtualization enabled!${n}"
      echo "Please reboot to apply changes"
      
    elif [[ "$OPTION" == "virt-off" ]]; then
      echo "Disabling virtualization..."
      
      if [ "$(systemctl is-enabled libvirtd.service 2>/dev/null)" == "enabled" ]; then
        echo "${red}Disabling${n} libvirtd"
        sudo systemctl disable --now libvirtd 2>/dev/null || true
      fi
      
      echo "Removing virt-manager..."
      flatpak uninstall -y org.virt_manager.virt-manager 2>/dev/null || true
      
      echo "Removing kernel args..."
      rpm-ostree kargs \
        --delete-if-present="kvm.ignore_msrs=1" \
        --delete-if-present="kvm.report_ignored_msrs=0"
      
      echo "${green}Virtualization disabled!${n}"
      echo "Please reboot to apply changes"
      
    elif [[ "$OPTION" == "group" ]]; then
      echo "Adding $USER to libvirt group..."
      if ! grep -q "^libvirt" /etc/group; then
        grep '^libvirt' /usr/lib/group | sudo tee -a /etc/group > /dev/null 2>/dev/null || true
      fi
      sudo usermod -aG libvirt $USER
      echo "${green}Done!${n} You may need to log out and back in for changes to take effect"
      
    elif [[ "$OPTION" == "vfio-on" ]]; then
      echo "Enabling VFIO for GPU passthrough..."
      
      CPU_VENDOR=$(grep "vendor_id" "/proc/cpuinfo" | uniq | awk -F": " '{ print $2 }')
      VENDOR_KARG=""
      
      if [[ ${CPU_VENDOR} == "AuthenticAMD" ]]; then
        VENDOR_KARG="amd_iommu=on"
      elif [[ ${CPU_VENDOR} == "GenuineIntel" ]]; then
        VENDOR_KARG="intel_iommu=on"
      else
        echo "Could not determine CPU vendor"
        exit 1
      fi
      
      rpm-ostree initramfs --enable
      rpm-ostree kargs \
        --append-if-missing="${VENDOR_KARG}" \
        --append-if-missing="iommu=pt" \
        --append-if-missing="rd.driver.pre=vfio-pci" \
        --append-if-missing="vfio_pci.disable_vga=1"
      
      echo "${green}VFIO enabled!${n}"
      echo "Make sure you enable IOMMU/VT-d/AMD-v in your BIOS!"
      echo "After reboot, use 'rpm-ostree kargs --append-if-missing=\"vfio_pci.ids=xxxx:yyyy\"' to bind your GPU"
      echo "Please reboot to apply changes"
      
    elif [[ "$OPTION" == "vfio-off" ]]; then
      echo "Disabling VFIO..."
      rpm-ostree kargs \
        --delete-if-present="iommu=pt" \
        --delete-if-present="iommu=on" \
        --delete-if-present="amd_iommu=on" \
        --delete-if-present="intel_iommu=on" \
        --delete-if-present="rd.driver.pre=vfio-pci" \
        --delete-if-present="vfio_pci.disable_vga=1"
      
      sudo rm -f /etc/dracut.conf.d/vfio.conf 2>/dev/null || true
      
      echo "${green}VFIO disabled!${n}"
      echo "Please reboot to apply changes"
    fi
