{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    #pkgs.pass-wayland
    (pass.withExtensions
      (exts: [exts.pass-otp]))
  ];

  programs.browserpass.enable = true;
  programs.firefox.nativeMessagingHosts.browserpass = true;
  programs.chromium.extensions = [
    "naepdomgkenhinolocfifgehidddafch"
  ];

  programs.gnupg.agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry-gnome3;
    enableSSHSupport = true;
  };

  environment.variables = {
    PASSWORD_STORE_DIR = "$HOME/.local/share/password-store";
  };
}
