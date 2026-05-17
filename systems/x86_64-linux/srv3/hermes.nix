{
  lib,
  pkgs,
  ...
}: {
  # Hermes Agent — AI coding assistant (Nous Research) via official NixOS module
  services.hermes-agent = {
    enable = true;
    container.enable = true;

    # Przenosimy dane agenta by lądowały tam, gdzie dotychczas.
    stateDir = "/srv/hermes/data";

    # Dodajemy klucze i sekrety współdzielone w postaci pliku environmentFiles.
    environmentFiles = ["/srv/hermes/workspace.env"];

    # Deklarujemy nie-tajne zmienne środowiskowe, które aktywują dashboard/API.
    environment = {
      HERMES_DASHBOARD = "1";
      API_SERVER_ENABLED = "true";
      API_SERVER_HOST = "0.0.0.0";
    };
  };
}
