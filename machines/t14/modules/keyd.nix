{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["04b3:301e:b108cf48"]; # Applies to all keyboards
      settings = {
        main = {
          leftalt = "leftmeta";
          leftmeta = "layer(super_layer)";
          # "leftmeta+left" = "alt+left";
        };
        "super_layer:A" = {
          left = "left";
        };
      };
    };
  };
}
