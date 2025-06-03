{ config, pkgs, ... }:

let
  gpt-script = pkgs.writeScriptBin "gpt" ''
    #!${pkgs.bash}/bin/bash
    
    # Set PATH to include all dependencies
    export PATH="${pkgs.lib.makeBinPath [ pkgs.curl pkgs.jq pkgs.coreutils pkgs.gnused ]}:$PATH"
    
    ${builtins.readFile ./gpt.sh}
  '';
in
{
  # Install the script as a package
  environment.systemPackages = [ gpt-script ];
}
