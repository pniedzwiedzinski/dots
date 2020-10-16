{ config, ... }:

{
  xdg.configHome."mimeapps.list".text = ''
    [Default Applications]

    application/rss+xml=larbs-news.desktop
    x-scheme-handler/mailto=larbs-mail.desktop;
    x-scheme-handler/gemini=amfora.desktop

    # xdg-open will use these settings to determine how to open filetypes.
    # These .desktop entries can also be seen and changed in ~/.local/share/applications/

    text/x-shellscript=text.desktop;
    x-scheme-handler/magnet=torrent.desktop;
    application/x-bittorrent=torrent.desktop;
    text/plain=text.desktop;
    application/postscript=pdf.desktop;
    application/pdf=pdf.desktop;
    image/png=img.desktop;
    image/jpeg=img.desktop;
    image/gif=img.desktop;
    video/x-matroska=video.desktop
    x-scheme-handler/lbry=lbry.desktop
    inode/directory=file.desktop
  '';
