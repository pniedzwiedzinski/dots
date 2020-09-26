pkgs:

let
  isDarwin = builtins.currentSystem == "x86_64-darwin";
  platformAliases =
    if isDarwin then ../../platforms/darwin/aliases.nix
    else ../../platforms/linux/aliases.nix
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
    shellAliases = import ../aliases.nix // import platformAliases;
    defaultKeymap = "viins";
    initExtraBeforeCompInit = builtins.readFile ./precomp.zshrc;
    initExtra = ''
      _comp_options+=(globdots)
    '';

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
