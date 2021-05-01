{pkgs, ...}:
let
  terminal = symlinkJoin {
    name = "alacritty";
    paths = [ pkgs.alacritty ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/alacritty \
        --add-flags "--config-file ${./alacritty.yml}"
    ''
  };
  dwl = (pkgs.dwl.overrideDerivation (old: {
    src = pkgs.fetchFromGitHub {
      owner = "djpohly";
      repo = "dwl";
      rev = "v0.2.1";
      sha256 = "sha256:0js8xjc2rx1ml6s58s90jrak5n7vh3kj5na2j4yy3qy0cb501xcm";
    };
    patches = [];
  })).override {
    conf = ./dwl.config.h;
  };
in
  {
    environment.systemPackages = [
      pkgs.firefox-wayland
      terminal
      dwl
      pkgs.bemenu
      pkgs.wl_clipboard
      pkgs.grim
      pkgs.slurp
      pkgs.wf-recorder
    ];
  }
