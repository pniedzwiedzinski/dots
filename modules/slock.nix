{ config, pkgs, ... }:

let
  slock = pkgs.slock.overrideAttrs(oldAttrs: {
    buildInputs = oldAttrs.buildInputs ++ [
      # pkgs.imlib2
      # pkgs.linux-pam
      pkgs.xlibs.libXinerama
    ];
    patches = [
      # ../platforms/linux/xorg/slock/slock-pam_auth-20190207-35633d4.diff
      ../platforms/linux/xorg/slock/slock-capscolor-20170106-2d2a21a.diff
      ../platforms/linux/xorg/slock/slock-dpms-1.4.diff
      ../platforms/linux/xorg/slock/slock-mediakeys.diff
    ];
  });
in {
  environment.systemPackages = [ slock ];
  security.wrappers.slock.source = "${slock.out}/bin/slock";
  # services.xserver.xautolock = {
  #   enable = true;
  #   locker = "${config.security.wrapperDir}/slock";
  #   enableNotifier = true;
  #   notifier = "${pkgs.libnotify}/bin/notify-send \"Locking in 10 seconds\"";
  #   killer = "/run/current-system/systemd/bin/systemctl suspend-then-hibernate";
  #   killtime = 30;
  #   extraOptions = [ "-detectsleep" ];
  # };
  programs.xss-lock = {
    enable = true;
    lockerCommand = "${config.security.wrapperDir}/slock";
  };
}
