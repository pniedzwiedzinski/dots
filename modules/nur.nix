{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball {
      url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
    }) {
      inherit pkgs;
    };
  };
  nix.settings.substituters = [
    "https://cache.nixos.org"
    "https://pn.cachix.org"
  ];
}
