{
  vim = "nvim";
  cfd = "cd ~/.config/nixpkgs";
  ch = "v ~/.config/nixpkgs/home.nix";
  github = "gh repo view --web";

  cp = "cp -iv";
  mv = "mv -iv";
  rm = "rm -iv";
  mkd = "mkdir -pv";
  yt = "youtube-dl --add-metadata -i";
  yta = "yt -x -f bestaudio/best";
  ffmpeg = "ffmpeg -hide_banner";

  # Git aliases
  gs = "git status";
  ga = "git add";
  gc = "git commit";
  gl = "git lg";
  gd = "git diff";

  calibre = "calibre --with-library=~/books";
}
