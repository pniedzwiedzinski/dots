{
  config,
  pkgs,
  ...
}: {
  home.username = "pn";
  home.homeDirectory = "/home/pn";

  programs.brave = {
    enable = false;
    package = pkgs.brave.overrideAttrs (oldAttrs: {
      commandLineArgs = [
        "--profile-directory=${config.home.homeDirectory}/.config/BraveSoftware/Brave-Browser/Default"
      ];
    });
    extensions = [
      {id = "fjcldmjmjhkklehbacihaiopjklihlgg";}
    ];
  };

  xdg.userDirs = {
    enable = true;
    documents = "${config.home.homeDirectory}/docs";
    download = "${config.home.homeDirectory}/dwn";
    music = "${config.home.homeDirectory}/music";
    pictures = "${config.home.homeDirectory}/pics";
    videos = "${config.home.homeDirectory}/vids";
    templates = "${config.home.homeDirectory}/templates";
  };

  programs.git = {
    enable = true;
    package = pkgs.gitFull;

    signing = {
      key = "pniedzwiedzinski19@gmail.com";
      signByDefault = true;
    };

    settings = {
      user = {
        name = "Patryk Niedźwiedziński";
        email = "pniedzwiedzinski19@gmail.com";
      };
      alias = {
        lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      };

      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      url."ssh://git@github.com/pniedzwiedzinski/".insteadOf = "pn:";
      url."ssh://git@gitlab.com/".insteadOf = "https://gitlab.com/";
      url."ssh://git@bitbucket.org/".insteadOf = "https://bitbucket.org/";

      sendemail = {
        smtpserver = "${pkgs.msmtp}/bin/msmtp";
        smtpserveroption = [
          "-a"
          "pniedzwiedzinski19@gmail.com"
        ];
      };
    };
  };

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";
}
