[
  (self: super:
  let rev1 = "bd7360b";
  in {
    neovim-unwrapped = super.neovim-unwrapped.overrideAttrs (oldAttrs: rec {
      version = "nightly-${rev1}";
      src = super.fetchFromGitHub rec {
        name = "source-${oldAttrs.pname}-${version}-${rev1}";
        owner = "neovim";
        repo = "neovim";
        rev = rev1;
        sha256 = "0lg9hwvcaiwj9z6wp9rw80czfs7l3bwvcc916fz87jxafp683m37";
      };
    });

    brave-beta = super.brave.overrideAttrs (oldAttrs: rec {
      version = "1.18.57";
      src = super.fetchurl {
        url = "https://github.com/brave/brave-browser/releases/download/v${version}/brave-browser-beta_${version}_amd64.deb";
        sha256 = "11v7j13ids7dw1lpcjc5cw18vk6x9jc6ylsd2na7cgmygwx0f3ms";
      };
    });
  })
]
