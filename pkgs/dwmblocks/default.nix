pkgs:
  pkgs.nur.repos.pn.dwmblocks.override {
    patches = [
      ./dwmblocks.diff
      ./dwmblocks-todo.diff
    ];
  }
