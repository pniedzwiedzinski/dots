{pkgs, ...}: {
  # 2. Configure the Xerox backend with your specific ID
  hardware.sane.extraBackends = [
    (pkgs.writeTextFile {
      name = "xerox-mfp-config";
      destination = "/etc/sane.d/xerox_mfp.conf";
      text = ''
        # Xerox WorkCentre 3325
        # Vendor: 0924, Product: 3CF8
        usb 0x0924 0x3cf8
      '';
    })
  ];

  # 3. Add a Udev rule to fix permissions (Crucial for USB)
  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0924", ATTRS{idProduct}=="3cf8", MODE="0660", GROUP="scanner", ENV{libsane_matched}="yes"
  '';
}
