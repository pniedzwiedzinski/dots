{
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = ["04b3:301e:b108cf48"]; # Applies to all keyboards
      settings.main = {
        alt = "super"; # Remap Left Alt to Super
      };
    };
  };
}
