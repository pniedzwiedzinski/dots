{
  pkgs ? import <nixpkgs> { },
}:

pkgs.writeShellApplication {
  name = "rebuild";

  # Define dependencies here. They will be automatically added to the PATH.
  runtimeInputs = with pkgs; [
    libnotify
    git
  ];

  # distinct from the original module: we assume gpt.sh is in the same directory
  text = builtins.readFile ./rebuild.sh;
}
