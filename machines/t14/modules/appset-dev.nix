{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    busybox
    vscode
    vim
    jq
    python3
    python3Packages.pip
    nodejs
    deploy-rs
    nixfmt-rfc-style
    devenv
  ];

  virtualisation.docker.enable = true;
  users.users.pn.extraGroups = ["docker"];
}
