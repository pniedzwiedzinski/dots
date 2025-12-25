{ config, pkgs, ... }:
{
  security.sudo.enable = false;
  security.doas = {
    enable = true;
    wheelNeedsPassword = false;
    extraRules = [{
      groups = [ "wheel" ];
      noPass = true;
      # keepEnv = true;
      # I need to set NIX_PATH explicitly, since my user and root use different paths
      setEnv = [ "NIX_PATH=nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels" ];
    }];
  };
  environment.shellAliases = {
    sudo = "doas";
  };
  environment.systemPackages = [
    (pkgs.linkFarm "sudo" [ {
      name = "bin/sudo";
      path = "${config.security.wrapperDir}/doas";
    }])
  ];
}
