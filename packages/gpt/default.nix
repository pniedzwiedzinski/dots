{
  pkgs ? import <nixpkgs> { },
}:

pkgs.writeShellApplication {
  name = "gpt";

  # Define dependencies here. They will be automatically added to the PATH.
  runtimeInputs = with pkgs; [
    curl
    jq
    coreutils
    gnused
  ];

  # distinct from the original module: we assume gpt.sh is in the same directory
  text = builtins.readFile ./gpt.sh;
}
