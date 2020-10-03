{
  allowUnfree = true;
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball {
      url = "https://github.com/nix-community/NUR/archive/ed5311bdee0d9f7e41949da1c1254f7e982193d6.tar.gz";
      sha256 = "038fpr5pfsgx9ikpnx39bv886yfixwfkpmb8yd4gvaccazral5h8";
    }) {
      inherit pkgs;
    };
  };
}
