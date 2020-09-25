{
  allowUnfree = true;
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball {
      url = "https://github.com/nix-community/NUR/archive/b42e8200dc093babc67634d58ea2cc88c22ad786.tar.gz";
      sha256 = "1msijla8ak2dg17xxkj3y3p2877k5icp9va35vsxza4n5inqk5z1";
    }) {
      inherit pkgs;
    };
  };
}
