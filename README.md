# device-batteries

Widżet na panel KDE Plasma 6 (SteamOS / Steam Machine), który pokazuje poziom baterii urządzeń bezprzewodowych:

```
⌨ 59%  🖱 81%  🎧 73%
```

| Urządzenie | Jak odczytywane |
|---|---|
| Klawiatura **Redragon K719WG-RGB-PRO** (odbiornik 2.4G `320f:511c`) | Własny protokół HID producenta, rozpracowany na podstawie oficjalnej aplikacji (opis niżej) |
| Mysz **Logitech** (np. PRO X 2) | Sterownik `hidpp` w jądrze → UPower |
| **AirPods Pro** | Protokół Apple AAP przez L2CAP (PSM `0x1001`), ten sam co w projekcie LibrePods |
| Inne urządzenia z baterią w UPower | UPower |

Widżet odświeża się co minutę i po kliknięciu. Po najechaniu kursorem pokazuje szczegóły (lewa i prawa słuchawka, etui). ⚡ oznacza ładowanie.

## Instalacja

```bash
./install.sh
```

Pliki trafiają do `~/.local/bin` i `~/.local/share/plasma/plasmoids`, więc przetrwają aktualizacje SteamOS. Nie są potrzebne uprawnienia roota: użytkownik zalogowany przy ekranie ma dostęp do `/dev/hidraw*` (uaccess).

## Protokół klawiatury Redragon K719 (2.4G)

Interfejs nr 1 odbiornika (`input1`, usage page `0xFF1C`, usage `0x92`), report ID `4`, pakiety 64-bajtowe w obie strony:

```
[0]   0x04          report ID
[1-2] suma          16-bitowa suma bajtów 3..63 (little endian)
[3]   polecenie
[4]   długość danych
[5-6] offset (LE)
[7]   status w odpowiedzi (0x00 OK, 0xFF/0xFE błąd)
[8..] dane
```

- `0x1a` → **bajt [8] odpowiedzi = poziom baterii w %** (zgodny z ekranem LCD klawiatury).
- Polecenia używane przez oficjalną aplikację: `0x01`/`0x02` (początek/koniec sesji), odczyty: `0x03`, `0x05`, `0x07`, `0x0a`, `0x1a`, `0x1b`; zapisy: `0x06`, `0x09`, `0x0b`, `0x12`, `0x15`, `0x17`, `0x21`. `0x1c`, `0x23` i `0xaa` nie przenoszą danych, a jedno z nich to prawdopodobnie reset do ustawień fabrycznych. **Nie wysyłaj poleceń, których nie znasz.**
- Klawiatura nie wysyła stanu ładowania.

## Protokół AirPods (AAP)

Połączenie L2CAP `SOCK_SEQPACKET` do PSM `0x1001`, następnie:

```
00 00 04 00 01 00 02 00 00 00 00 00 00 00 00 00   handshake
04 00 04 00 0f 00 ff ff ff ff                     prośba o powiadomienia
```

Odpowiedź z baterią: `04 00 04 00 04 00 <n>`, a po nim `n` rekordów `[typ] 01 [poziom] [status] 01`. Typy: `04` lewa, `02` prawa, `08` etui. Statusy: `01` ładowanie, `02` bez ładowania, `04` niepodłączone.

## Odinstalowanie

```bash
rm -rf ~/.local/bin/device-batteries ~/.local/share/plasma/plasmoids/org.local.devicebatteries
```

Następnie usuń widżet z panelu (prawy klik → Usuń).
