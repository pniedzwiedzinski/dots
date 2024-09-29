#!/bin/sh

theme=$(gsettings get org.gnome.desktop.interface color-scheme)

echo $theme
if [ "$theme" = "'prefer-dark'" ]; then
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-light'
else
	gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
fi

