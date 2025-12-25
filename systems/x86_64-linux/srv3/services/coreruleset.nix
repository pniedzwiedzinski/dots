{ stdenv, fetchFromGitHub }:
stdenv.mkDerivation {
  pname = "coreruleset";
  version = "3.3.0";

  src = fetchFromGitHub {
    owner = "coreruleset";
    repo = "coreruleset";
    rev = "v3.3.0";
    sha256 = "sha256:10z1051iwna5x8b8cl29frs5nx3s6ip7hc4mjkgh7vkck8ly4pjm";
  };

  installPhase = ''
    mkdir $out
    cp crs-setup.conf.example $out/crs-setup.conf
    cp -r rules $out
    for f in rules/*.conf; do
      echo "Include \"$out/$f\"" >> $out/all-rules.conf
    done
  '';
}
