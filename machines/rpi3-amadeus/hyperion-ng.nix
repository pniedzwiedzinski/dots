{ stdenv, fetchurl, fetchzip, autoPatchelfHook, callPackage,
expat, glib, systemd, libX11, libXrandr, fontconfig, tlf, ncurses5, bzip2,
readline70, openssl, db, libglvnd, libusb }:
with stdenv.lib;
let
  version = "2.0.0-alpha.9";

  srcAarch64 = fetchurl {
    url = "https://github.com/hyperion-project/hyperion.ng/releases/download/${version}/Hyperion-${version}-Linux-aarch64.tar.gz";
    sha256 = "09wvlhp5c1mkvjsgbsiy402cx8na7qykwgv4waivc7m5ns4sl2mf";
  };

  srcX86 = fetchurl {
    url = "https://github.com/hyperion-project/hyperion.ng/releases/download/${version}/Hyperion-${version}-Linux-x86_64.tar.gz";
    sha256 = "1gkjzqkh6qbwzkrdrg9xmznh6b676kmdlw54drqwfycakb7riad2";
  };

  mpdecimal = callPackage ./mpdecimal.nix {};

  bzip2_linked = stdenv.mkDerivation {
    name = "bzip2-linked";
    unpackPhase = "true";
    installPhase = ''
      mkdir -p $out/lib
      cp -r ${bzip2.out}/lib/libbz2.so.1.0.6 $out/lib
      ln -s $out/lib/libbz2.so.1.0.6 $out/lib/libbz2.so.1.0
    '';
  };

  python3 = (import (fetchzip {
    url = "https://github.com/nixos/nixpkgs/archive/7731621c81b5cd601a176c2109b44c5295049f20.zip";
    # Please update this hash with the one nix says on the first build attempt
    sha256 = "0gdf2kkh3qcn9r300sl4khcg0fnixarjcil9pv9hami3dqjbpngv";
  }) { }).python3;
in
stdenv.mkDerivation {
  inherit version;
  pname = "hyperion-ng";

  src = srcAarch64;

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    python3
    systemd
    stdenv.cc.cc.lib
    fontconfig.lib
    tlf
    ncurses5
    mpdecimal
    glib
    readline70
    openssl
    db
    libglvnd
    libusb
    expat
    libX11
    libXrandr

    bzip2_linked
  ];

  sourceRoot = "share/hyperion";

  buildPhase = "";
  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp -r bin $out
    cp -r lib $out

    #ln -s ${bzip2}/lib/libbz2.so.1.0.6 $out/lib/libbz2.so.1.0
  '';

  meta = {
    description = "Hyperion is an open source ambient light software. Feel free to join us and contribute new features!";
    homepage = "https://hyperion-project.org/";
  };
}
