{
  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball {
      url = "https://github.com/nix-community/NUR/archive/master.tar.gz";
    }) {
      inherit pkgs;
    };
  };
}
