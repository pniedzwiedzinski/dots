{ stdenv, fetchFromGitHub, libmodsecurity }:
let
  pname = "ModSecurity-nginx";
  version = "1.0.1";
in
stdenv.mkDerivation {
  inherit pname version;

  src = fetchFromGitHub {
    owner = "SpiderLabs";
    repo = "ModSecurity-nginx";
    rev = "v${version}";
    sha256 = "sha256:0cbb3g3g4v6q5zc6an212ia5kjjad62bidnkm8b70i4qv1615pzf";
  };

  inputs = [ libmodsecurity ];

}
 
