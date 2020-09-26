pkgs:
{
  home.packages = with pkgs; [
    capitaine-cursors
    papirus-icon-theme
    hicolor-icon-theme
  ];

  gtk = {
    enable = true;
    theme.name = "gruvbox-dark-hard";
    iconTheme.name = "Papirus";
    font.name = "Noto Sans 10";
    gtk3.extraConfig = {
      gtk-cursor-theme-name = "capitaine-cursors";
      gtk-application-prefer-dark-theme=true;
    };
    gtk3.extraCss = ''
    window decoration {
    margin: 0;
    border: none;
    }
    '';
    gtk2.extraConfig = ''
      gtk-cursor-theme-name="capitaine-cursors"
    '';
  };
}
