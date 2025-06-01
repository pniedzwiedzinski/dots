{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["04b3:301e:b108cf48"]; # Applies to all keyboards
      settings.main = {
        leftalt = "leftmeta";
        "leftmeta+left" = "leftalt+left";
      };
    };
  };
}
