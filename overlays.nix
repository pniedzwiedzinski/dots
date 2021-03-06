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

    brave17 = (import (builtins.fetchTarball {
      url = "https://github.com/buckley310/nixpkgs/archive/brave.tar.gz";
      sha256 = "08m6w0d2z8n0wlvffgfaglyrydxw895z0hk7x2b41x44zkrc3zx5";
    }) { }).brave;

    discord = super.discord.overrideAttrs (_: rec {
      version = "0.0.13";
      src = super.fetchurl {
        url = "https://dl.discordapp.net/apps/linux/${version}/discord-${version}.tar.gz";
        sha256 = "0d5z6cbj9dg3hjw84pyg75f8dwdvi2mqxb9ic8dfqzk064ssiv7y";
      };
    });

  })
]
