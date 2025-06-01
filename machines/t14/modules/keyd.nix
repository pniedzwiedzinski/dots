{
  services.keyd = {
    enable = false;
    keyboards.default = {
      ids = ["04b3:301e:b108cf48"]; # Applies to all keyboards
      settings = {
        main = {
          leftalt = "leftmeta";
          "leftcontrol+left" = "left";
        };
      };
    };
  };
}
