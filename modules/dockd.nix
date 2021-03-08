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
height=1080
width=3840
mm_height=311
mm_width=1041

[CRTC]
crtc=63
x=0
y=0
rotation=1
mode=1920x1080
outputs_len=1
outputs_0=HDMI3

[CRTC]
crtc=64
x=1920
y=0
rotation=1
mode=1920x1080
outputs_len=1
outputs_0=DP2

[CRTC]
crtc=65
x=0
y=0
rotation=1
mode=None
outputs_len=0
     '';
      "dockd/undocked.conf".text = ''
[Screen]
height=768
width=1366
mm_height=201
mm_width=359

[CRTC]
crtc=63
x=0
y=0
rotation=1
mode=1366x768
outputs_len=1
outputs_0=LVDS1

[CRTC]
crtc=64
x=1920
y=0
rotation=1
mode=None
outputs_len=0

[CRTC]
crtc=65
x=0
y=0
rotation=1
mode=None
outputs_len=0


     '';
    };
  };
}
