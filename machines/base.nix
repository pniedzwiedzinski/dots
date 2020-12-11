## Base setup, absolute minimum

{ pkgs, ... }:
{

  imports = [
    ../modules/nur.nix
    ../users/pn.nix
  ];

  environment.systemPackages = with pkgs; [
    wget vim curl htop file
    stdenv git zip unzip
    dnsutils ripgrep jq
  ];

  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v22n";

  ## === Vim configuration ===
  programs.vim.defaultEditor = true;
  environment.etc."vim/vimrc".text = ''
    set undodir=$XDG_DATA_HOME/vim/undo
    set directory=$XDG_DATA_HOME/vim/swap
    set backupdir=$XDG_DATA_HOME/vim/backup
    set viewdir=$XDG_DATA_HOME/vim/view
    set viminfo+='1000,n$XDG_DATA_HOME/vim/viminfo
    set runtimepath=$XDG_CONFIG_HOME/vim,$VIMRUNTIME,$XDG_CONFIG_HOME/vim/after
  '';

  ## === ZSH configuration ===

  ## Make zsh the default shell
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  ## Cleanup home
  environment.etc."zshenv.local".text = ''
    export ZDOTDIR=$HOME/.config/zsh
  '';

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    histFile = "$XDG_DATA_HOME/zsh/history";

    syntaxHighlighting.enable = true;
  };

}
