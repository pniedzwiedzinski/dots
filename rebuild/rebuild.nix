{ stdenv, pkgs }:
pkgs.runCommand "rebuild" ''
  mkdir -p $out/bin
  cp ${./rebuild.sh} $out/bin/rebuild
'';
