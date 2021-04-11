{ makeWrapper, symlinkJoin, signal-desktop }:
symlinkJoin {
  name = "signal-desktop";
  paths = [ signal-desktop ];
  buildInputs = [ makeWrapper ];
  postBuild = ''
    wrapProgram $out/bin/signal-desktop \
      --add-flags "--use-tray-icon"
  '';
}
