{ config, lib, pkgs, ... }:

let
  cfg = config.programs.dockd;
in

{
  options = {
    programs.dockd = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          ThinkPad dock manager daemon.
        '';
      };
    };
  };

  config = lib.mkIf (cfg.enable) {
    environment.etc = {
      "dockd/docked.conf".text = ''
        [Screen]
        height=1920
        width=3000
        mm_height=506
        mm_width=791

        [CRTC]
        crtc=63
        x=0
        y=241
        rotation=1
        mode=1920x1080
        outputs_len=1
        outputs_0=HDMI-3

        [CRTC]
        crtc=64
        x=1920
        y=0
        rotation=2
        mode=1920x1080
        outputs_len=1
        outputs_0=DP-2
      '';

      "dockd/undocked.conf".text = ''
        [Screen]
        height=768
        width=1366
        mm_height=202
        mm_width=359

        [CRTC]
        crtc=63
        x=0
        y=0
        rotation=1
        mode=1366x768
        outputs_len=1
        outputs_0=LVDS-1

        [CRTC]
        crtc=64
        x=1920
        y=0
        rotation=2
        mode=None
        outputs_len=0
      '';
    };
  };
}
