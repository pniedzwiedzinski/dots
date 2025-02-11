{
  services.yggdrasil = {
    enable = true;
    persistentKeys = true;
    config = {
      Peers = [
        "tcp://51.75.44.73:50001"
        "tcp://176.223.130.120:22632"
      ];
    };
  };
}
