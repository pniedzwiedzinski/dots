{
  programs.mpv = {
    enable = true;
    config = {
      ytdl-format = "bestvideo[height<=?1080][fps<=?30]+bestaudio/best";
    };
  };
}
