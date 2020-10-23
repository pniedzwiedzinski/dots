{ pkgs, ... }:

let
  sent = pkgs.sent.override {
    patches = [
      ./gruvbox.patch
    ];
  };
in {
  home.packages = [
    sent
  ];
}
