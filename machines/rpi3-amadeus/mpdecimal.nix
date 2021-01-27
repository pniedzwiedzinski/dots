{ stdenv, fetchurl, gcc, binutils }:

let
  pname = "mpdecimal";
  version = "2.5.0";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchurl {
    url = "https://www.bytereef.org/software/${pname}/releases/${pname}-${version}.tar.gz";
    sha256 = "1jm0vzlcsapx9ilrvns4iyws6n5i48zpxykmklfpv98jivf7wh8m";
  };

  buildPhase = ''
    ./configure

    sed -i 's/-Wl,//' libmpdec/Makefile
    make
  '';

  installPhase = ''
    mkdir -p $out/lib
    cp libmpdec/*.so* $out/lib
  '';

}
