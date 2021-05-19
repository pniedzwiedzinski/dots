{ config, pkgs, ... }:

{
  config = {
    home.packages = [ pkgs.qutebrowser ];

    home.file.".config/qutebrowser/config.py".text = ''
      c.aliases = {}
      c.tabs.tabs_are_windows = True
      c.tabs.show = "multiple"
      c.statusbar.show = "in-mode"
      c.downloads.location.directory = "~/down"
      c.content.pdfjs = True
      c.content.javascript.enabled = False
      config.load_autoconfig()

      import subprocess
      import sys, os

      def read_xresources(prefix):
        props = {}
        x = subprocess.run(['xrdb', '-query'], stdout=subprocess.PIPE)
        lines = x.stdout.decode().split('\n')
        for line in filter(lambda l : l.startswith(prefix), lines):
          prop, _, value = line.partition(':\t')
          props[prop] = value
        return props

      xresources = read_xresources('*')

      black      =  xresources['*.color0']
      red        =  xresources['*.color1']
      green      =  xresources['*.color2']
      yellow     =  xresources['*.color3']
      blue       =  xresources['*.color4']
      magenta    =  xresources['*.color5']
      cyan       =  xresources['*.color6']
      white      =  xresources['*.color7']
      black_b    =  xresources['*.color8']
      red_b      =  xresources['*.color9']
      green_b    =  xresources['*.color10']
      yellow_b   =  xresources['*.color11']
      blue_b     =  xresources['*.color12']
      magenta_b  =  xresources['*.color13']
      cyan_b     =  xresources['*.color14']
      white_b    =  xresources['*.color15']
      bg         =  xresources['*.background']
      fg         =  xresources['*.foreground']
    '';
  };
}
