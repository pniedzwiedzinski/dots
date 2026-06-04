# Homelab Infrastructure 2.0 Proposal

## Zarys historyczny
W związku z powtarzającymi się awariami serwera `srv3` (niewyjaśnione zawieszenia, "hard lockups" skutkujące nagłym brakiem logów w journalu) i wynikającą z nich niedostępnością usług podczas nieobecności w domu, rozważane było wdrożenie architektury High Availability / Failover z automatyczną replikacją danych.

## Zidentyfikowane problemy w pierwotnej architekturze:
1. **Replikacja stanu baz danych (State Replication Issue):** Replikacja żywych baz danych (np. dla Immich, Paperless) poprzez współdzielenie plików (na poziomie systemu plików) rodzi ogromne ryzyko korupcji. Replikacja może szybko skopiować niepoprawny stan, w tym zaszyfrowane przez ransomware pliki.
2. **Split-Brain:** Brak jasnego rozjemcy przy zerwaniu komunikacji między węzłami z jednoczesnym zachowaniem zewnętrznego load balancingu.
3. **Zależność Home Assistanta:** Koncepcja wykorzystania gniazdka Tasmota kontrolowanego z Home Assistanta do restartowania `srv3` nie zadziała, ponieważ awaria `srv3` powoduje awarię samego Home Assistanta.
4. **Częściowa infrastruktura jako kod:** Obecnie nie cała konfiguracja jest w NixOS (część to luźne docker-compose w `/srv`), co utrudnia automatyczny provisioning pełnych klonów.

## Propozycja Docelowa: "Cold Standby & Dev Environment"

Zamiast skomplikowanego, obarczonego ryzykiem Active-Passive, proponuje się poniższe podejście:

### 1. Maszyna `srv6` (dawniej `backup`)
Serwer dotychczas nazywany `backup` zostanie zmieniony w repozytorium w maszynę `srv6`. Posłuży on dwóm celom:
- **Serwer Developerski:** Środowisko testowe dla nowych konfiguracji NixOS. Wszystkie współdzielone usługi z `srv3` zostaną wyodrębnione do modułów (`roles/homelab-services`). Nowe wersje aplikacji będą testowane na `srv6` z pustymi katalogami `/srv` przed zatwierdzeniem deploymentu na produkcyjnym `srv3`. To minimalizuje ryzyko uszkodzenia środowiska z powodu błędu konfiguracji.
- **Cold Standby:** Głównym miejscem zapisu dla danych aplikacyjnych w przypadku utraty `srv3` jest instancja Borg trzymana na `srv6`. W razie katastrofalnej awarii (spalenie dysku w srv3) zyskujemy możliwość ręcznego zainicjowania skryptu rozpakowującego backup Borga do lokalnego `/srv` na `srv6` i szybkiego uruchomienia tych samych kontenerów (dzięki współdzielonej konfiguracji z `srv3`).

### 2. Monitoring awarii `srv3`
Aby zapobiec permanentnym awariom sprzętowym skutkującym przerwami w dostępie, wprowadzono dwa mechanizmy tymczasowe, które następnie należy stale rozwijać:
- **Hardware Watchdog:** Skonfigurowany w systemd, aby po 60 sekundach zawieszenia kernela (hard lockup) sprzętowo restartował maszynę.
- **Netconsole (do implementacji w 2.0):** Możliwość zrzucania logów z awarii jądra (`dmesg` przed "śmiercią") poprzez UDP na log server/syslog, by ostatecznie zdiagnozować usterkę hardware'ową `srv3`.
