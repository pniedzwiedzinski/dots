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
    teams = super.teams.overrideAttrs (oldAttrs: rec {
      installPhase = ''
        mkdir -p $out/{opt,bin}
        rm share/teams/resources/app.asar.unpacked/node_modules/slimcore/bin/rect-overlay
        mv share/teams $out/opt/
        mv share $out/share
        substituteInPlace $out/share/applications/teams.desktop \
        --replace /usr/bin/ $out/bin/
        ln -s $out/opt/teams/teams $out/bin/
      '';
    });
  })
]
