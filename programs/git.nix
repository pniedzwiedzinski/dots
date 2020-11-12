{ pkgs, ... }:
{
  programs.git = {
    enable = true;
    package = pkgs.gitAndTools.gitFull;
    userName = "Patryk Niedźwiedziński";
    userEmail = "pniedzwiedzinski19@gmail.com";
    signing = {
      key = "pniedzwiedzinski19@gmail.com";
      signByDefault = true;
    };
    aliases = {
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
    };

    extraConfig = {
      url."ssh://git@github.com/".insteadOf = "https://github.com/";
      url."ssh://git@github.com/pniedzwiedzinski/".insteadOf = "pn:";
      url."ssh://git@gitlab.com/".insteadOf = "https://gitlab.com/";
      url."ssh://git@bitbucket.org/".insteadOf = "https://bitbucket.org/";

      sendemail = {
        smtpserver = "${pkgs.msmtp}/bin/msmtp";
        smtpserveroption  = [ "-a" "pniedzwiedzinski19@gmail.com" ];
      };
    };
  };
}
