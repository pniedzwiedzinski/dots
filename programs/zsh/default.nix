pkgs:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableAutosuggestions = true;
    autocd = true;
    dotDir = ".config/zsh";
    history = {
      path = "$HOME/.cache/zsh/history";
      size = 10000;
      save = 10000;
    };
    shellAliases = import ../aliases.nix;
    defaultKeymap = "viins";
    initExtraBeforeCompInit = builtins.readFile ./precomp.zshrc;
    initExtra = ''
      _comp_options+=(globdots)
    '';

    # plugins = [
    #   {
    #     name = "zsh-autosuggestions";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "zsh-users";
    #       repo = "zsh-autosuggestions";
    #       rev = "v0.6.3";
    #       sha256 = "1h8h2mz9wpjpymgl2p7pc146c1jgb3dggpvzwm9ln3in336wl95c";
    #     };
    #   }
    #   {
    #     name = "zsh-syntax-highlighting";
    #     src = pkgs.fetchFromGitHub {
    #       owner = "zsh-users";
    #       repo = "zsh-syntax-highlighting";
    #       rev = "be3882aeb054d01f6667facc31522e82f00b5e94";
    #       sha256 = "0w8x5ilpwx90s2s2y56vbzq92ircmrf0l5x8hz4g1nx3qzawv6af";
    #     };
    #   }
    # ];

    sessionVariables = rec {
      PROMPT="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b ";
      NVIM_TUI_ENABLE_TRUE_COLOR = "1";

      ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE = "fg=3";
      DEV_ALLOW_ITERM2_INTEGRATION = "1";

      EDITOR = "vim";
      VISUAL = EDITOR;
      GIT_EDITOR = EDITOR;

      GOPATH = "$HOME";

      PATH = "$HOME/.emacs.d/bin:$HOME/bin:$PATH";
    };
    # envExtra
    # profileExtra
    # loginExtra
    # logoutExtra
    # localVariables
  };
}
