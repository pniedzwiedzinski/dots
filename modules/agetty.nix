{ config, lib, pkgs, ... }:

with lib;

let

  autologinArg = optionalString (config.services.agetty.autologinUser != null) "--autologin ${config.services.agetty.autologinUser}";
  defaultUserArg = optionalString (config.services.agetty.defaultUser != null) "-n --login-options ${config.services.agetty.defaultUser}";
  gettyCmd = extraArgs: "@${pkgs.utillinux}/sbin/agetty agetty --login-program ${pkgs.shadow}/bin/login ${autologinArg} ${defaultUserArg} ${extraArgs}";

in

{

  ###### interface

  options = {

    services.agetty = {

      autologinUser = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Username of the account that will be automatically logged in at the console.
          If unspecified, a login prompt is shown as usual.
        '';
      };

      defaultUser = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          If set this will prompt only for password for given user (instead of login+password)
        '';
      };

      greetingLine = mkOption {
        type = types.str;
        description = ''
          Welcome line printed by agetty.
          The default shows current NixOS version label, machine type and tty.
        '';
      };

      helpLine = mkOption {
        type = types.lines;
        default = "";
        description = ''
          Help line printed by agetty below the welcome line.
          Used by the installation CD to give some hints on
          how to proceed.
        '';
      };

      serialSpeed = mkOption {
        type = types.listOf types.int;
        default = [ 115200 57600 38400 9600 ];
        example = [ 38400 9600 ];
        description = ''
            Bitrates to allow for agetty's listening on serial ports. Listing more
            bitrates gives more interoperability but at the cost of long delays
            for getting a sync on the line.
        '';
      };

    };

  };


  ###### implementation

  config = {
    # Note: this is set here rather than up there so that changing
    # nixos.label would not rebuild manual pages
    services.agetty.greetingLine = mkDefault ''<<< Welcome to NixOS ${config.system.nixos.label} (\m) - \l >>>'';

    systemd.services."getty@" =
      { serviceConfig.ExecStart = [
          "" # override upstream default with an empty ExecStart
          (gettyCmd "--noclear --keep-baud %I 115200,38400,9600 $TERM")
        ];
        restartIfChanged = false;
      };

    systemd.services."serial-getty@" =
      let speeds = concatStringsSep "," (map toString config.services.agetty.serialSpeed); in
      { serviceConfig.ExecStart = [
          "" # override upstream default with an empty ExecStart
          (gettyCmd "%I ${speeds} $TERM")
        ];
        restartIfChanged = false;
      };

    systemd.services."container-getty@" =
      { serviceConfig.ExecStart = [
          "" # override upstream default with an empty ExecStart
          (gettyCmd "--noclear --keep-baud pts/%I 115200,38400,9600 $TERM")
        ];
        restartIfChanged = false;
      };

    systemd.services.console-getty =
      { serviceConfig.ExecStart = [
          "" # override upstream default with an empty ExecStart
          (gettyCmd "--noclear --keep-baud console 115200,38400,9600 $TERM")
        ];
        serviceConfig.Restart = "always";
        restartIfChanged = false;
        enable = mkDefault config.boot.isContainer;
      };

    # environment.etc.issue =
    #   { # Friendly greeting on the virtual consoles.
    #     source = pkgs.writeText "issue" ''

    #       [1;32m${config.services.agetty.greetingLine}[0m
    #       ${config.services.agetty.helpLine}

    #     '';
    #   };

  };

}
