## Base setup, absolute minimum

{ pkgs, config, ... }:
{

  imports = [
     ../modules/nur.nix
    ../modules/doas.nix
  #  ../modules/internet.nix
  ];

  boot.tmp.cleanOnBoot = true;

  environment.systemPackages = with pkgs; [
    wget vim curl htop file
    stdenv git zip unzip
    dnsutils ripgrep jq
    fd fzf
    translate-shell
  ];

  console.font = "${pkgs.terminus_font}/share/consolefonts/ter-v22n";

  environment.shellAliases = {
    cf = "cd /etc/nixos/dots";
    gs = "git status";
    gc = "git commit";
    ga = "git add";
    gl = "git log";
    gd = "git diff";
    clone = "cd ~/code && git clone";
    ls = "ls --color=auto -hN --group-directories-first";
    rm = "rm -vI";
    cp = "cp -iv";
    mv = "mv -iv";
  };

  ## === XDG ===
  environment.variables = rec {
    PATH = "$HOME/scripts:$PATH";

    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_RUNTIME_DIR = "/run/user/$UID";

    # == XDG overrides ==
    ICEAUTHORITY = "${XDG_CACHE_HOME}/ICEauthority";
    XAUTHORITY = "$XDG_RUNTIME_DIR/Xauthority";
    LESSHISTFILE = "${XDG_CACHE_HOME}/lesshist";
    MPLAYER_HOME = "$XDG_CONFIG_HOME/mplayer";
  };

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

    promptInit = ''
      [ "$(tty)" = "/dev/tty1" ] && startx
      any-nix-shell zsh --info-right | source /dev/stdin
      autoload -U colors && colors
      PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "
    '';

    interactiveShellInit = ''
      setopt autocd		# Automatically cd into typed directory.
      stty stop undef		# Disable ctrl-s to freeze terminal.
      setopt interactive_comments

      # History in cache directory:
      HISTSIZE=10000000
      SAVEHIST=10000000

      # Load aliases and shortcuts if existent.
      [ -f "''\${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "''\${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
      [ -f "''\${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "''\${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
      [ -f "''\${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "''\${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

      # Basic auto/tab complete:
      autoload -U compinit
      zstyle ':completion:*' menu select
      zmodload zsh/complist
      compinit
      _comp_options+=(globdots)		# Include hidden files.

      # vi mode
      bindkey -v
      export KEYTIMEOUT=1

      # Use vim keys in tab complete menu:
      bindkey -M menuselect 'h' vi-backward-char
      bindkey -M menuselect 'k' vi-up-line-or-history
      bindkey -M menuselect 'l' vi-forward-char
      bindkey -M menuselect 'j' vi-down-line-or-history
      bindkey '^R' history-incremental-search-backward
      bindkey -v '^?' backward-delete-char

      # Change cursor shape for different vi modes.
      function zle-keymap-select {
        if [[ ''\${KEYMAP} == vicmd ]] ||
           [[ $1 = 'block' ]]; then
          echo -ne '\e[1 q'
        elif [[ ''\${KEYMAP} == main ]] ||
             [[ ''\${KEYMAP} == viins ]] ||
             [[ ''\${KEYMAP} = "" ]] ||
             [[ $1 = 'beam' ]]; then
          echo -ne '\e[5 q'
        fi
      }
      zle -N zle-keymap-select
      zle-line-init() {
          zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
          echo -ne "\e[5 q"
      }
      zle -N zle-line-init
      echo -ne '\e[5 q' # Use beam shape cursor on startup.
      preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

      # Use lf to switch directories and bind it to ctrl-o
      lfcd () {
          tmp="$(mktemp)"
          lf -last-dir-path="$tmp" "$@"
          if [ -f "$tmp" ]; then
              dir="$(cat "$tmp")"
              rm -f "$tmp" >/dev/null
              [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
          fi
      }
      bindkey -s '^o' 'lfcd\n'

      bindkey -s '^a' 'bc -lq\n'

      bindkey -s '^f' 'cd "$(dirname "$(fzf)")"\n'

      bindkey '^[[P' delete-char

      # Edit line in vim with ctrl-e:
      autoload edit-command-line; zle -N edit-command-line
      bindkey '^e' edit-command-line
    '';



  };

}
