1. **Zaktualizuj konfigurację `/opt/hermes/docker-compose.yml` (wymóg z treści zadania)**
   - Zaktualizuję plik `/opt/hermes/docker-compose.yml`, aby dodać serwis `webui` oparty o obraz `hermes-webui`.
   - Zastosuję `network_mode: host`, montowanie `/opt/data`, port `8787` oraz podane zmienne środowiskowe `HERMES_WEBUI_PASSWORD` i `HERMES_WEBUI_WORKSPACE`.
2. **Dodaj kontener `hermes-webui` do konfiguracji NixOS**
   - W pliku `systems/x86_64-linux/srv3/hermes.nix` dodam nowy kontener w ramach `virtualisation.oci-containers`.
   - Obraz: np. `nesquena/hermes-webui` (lub odpowiedni).
   - Port 8787.
   - Zamontuję odpowiednie wolumeny (podobnie jak w pozostałych kontenerach z uwzględnieniem ścieżek hosta `/srv/hermes/data` do `/opt/data` w kontenerze).
   - Skonfiguruję zmienne środowiskowe, takie jak `HERMES_WEBUI_PASSWORD` i `HERMES_WEBUI_WORKSPACE`.
3. **Konfiguracja Routingu Traefik**
   - Zgodnie ze wskazówkami (oraz preferencjami `configuration.nix`) dodam odpowiednie reguły routingu do `systems/x86_64-linux/srv3/configuration.nix`.
   - Aby zapewnić pełną zgodność z istniejącą logiką (lista makra `makeServices`), dodam port lokalnego `hermes-webui` (czyli port 8787).
   - Zdefiniuję ruter dla `hermes.niedzwiedzinski.pl` (z `certResolver = "letsencrypt"`) i ruter dla domeny tailscale `hermes.srv3.tailnet.ts.net` (z `certResolver = "tailscale"`) używając `dynamicConfigOptions.http.routers` i ewentualnie `.services`. Upewnię się, że domena publiczna `niedzwiedzinski.pl` jest poprawnie dodana w sekcji let's encrypt/traefik lub po prostu zadeklarowana we właściwym miejscu tak jak wymagano.
4. **Kroki Pre-commit i Zgłoszenie**
   - Zapewnię wykonanie instrukcji przed-komitowych (`pre_commit_instructions`) aby upewnić się, że testy, sprawdzenia, recenzje i autorefleksja przebiegły pomyślnie przed wywołaniem narzędzia `submit`.
