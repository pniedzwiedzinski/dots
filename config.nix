{
  allowUnfree = true;
  packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball {
      url = "https://github.com/nix-community/NUR/archive/5e6c5deca9fd7ef8c2151ec9b2c55c7fd3fa380f.tar.gz";
      sha256 = "0f6zfld7pxy9dx3426yddfk9xx1ma2h9wdw31kw31d4w35cbmzcp";
    }) {
      inherit pkgs;
    };
  };
}
