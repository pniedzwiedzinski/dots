{ config, ... }:
let
  spotifyUsername = "pboss.n@gmail.com";
  passwdCmd = "pass show spotify.com | head -n 1";
in
{
  xdg.configFile."spotifyd/spotifyd.conf".text = ''
    [global]
    # Fill this in with your Spotify login.
    username = ${spotifyUsername}
    password_cmd = "${passwdCmd}"


    # How this machine shows up in Spotify Connect.
    device_name = spotifyd
    device_type = computer

    # This is the default location of Spotify's cache, so just replace LOGIN_NAME
    # with your macOS login name (type `whoami` at a Terminal window).
    cache_path = ${config.home.homeDirectory}/Library/Application Support/Spotify/PersistentCache/Storage
    no_audio_cache = false

    # Various playback options. Tweak these if Spotify is too quiet.
    bitrate = 320
    volume_normalisation = true
    normalisation_pregain = -10

    # These need to be set, but don't need to be changed.
    backend = rodio
    mixer = PCM
    volume_controller = softvol
    zeroconf_port = 1234
  '';
}
