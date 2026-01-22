{pkgs, ...}: {
  hardware.sane.extraBackends = [
    (pkgs.writeTextFile {
      name = "xerox-mfp-config";
      destination = "/etc/sane.d/xerox_mfp.conf";
      text = ''
        # Xerox WorkCentre 3325
        usb 0x0924 0x3cf8
      '';
    })
  ];

  services.udev.extraRules = ''
    SUBSYSTEM=="usb", ATTRS{idVendor}=="0924", ATTRS{idProduct}=="3cf8", MODE="0660", GROUP="lp", ENV{libsane_matched}="yes"
  '';

  services.printing = {
    enable = true;
    drivers = with pkgs; [
      gutenprint
      gutenprintBin
      samsung-unified-linux-driver # To jest kluczowy sterownik dla tego modelu
      splix
    ];
  };

  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  environment.systemPackages = [
    pkgs.system-config-printer
    pkgs.usbutils # Przydatne do debugowania (lsusb)
  ];
}
