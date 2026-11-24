# device-batteries

A KDE Plasma 6 panel widget (SteamOS / Steam Machine) that shows the battery levels of wireless peripherals:

![Widget on the panel](docs/screenshot.png)

| Device | How it is read |
|---|---|
| **Redragon K719WG-RGB-PRO** keyboard (2.4G receiver `320f:511c`) | Vendor HID protocol, reverse-engineered from the official Windows app (see below) |
| **Logitech** mouse (e.g. PRO X 2) | Kernel `hidpp` driver → UPower |
| **AirPods Pro** | Apple AAP protocol over L2CAP (PSM `0x1001`), the same one used by LibrePods |
| Other battery devices known to UPower | UPower |

The widget refreshes every minute and on click. Hovering shows details (left/right earbud, case). ⚡ means charging.

## Installation

```bash
./install.sh
```

Files go to `~/.local/bin` and `~/.local/share/plasma/plasmoids`, so they survive SteamOS updates. No root needed: the user logged in at the seat already has access to `/dev/hidraw*` (uaccess).

## Redragon K719 protocol (2.4G)

Receiver interface 1 (`input1`, usage page `0xFF1C`, usage `0x92`), report ID `4`, 64-byte packets in both directions:

```
[0]   0x04          report ID
[1-2] checksum      16-bit sum of bytes 3..63 (little endian)
[3]   command
[4]   data length
[5-6] offset (LE)
[7]   status in the reply (0x00 OK, 0xFF/0xFE error)
[8..] data
```

- `0x1a` → **reply byte [8] = battery level in %** (matches the keyboard's LCD).
- Commands used by the official app: `0x01`/`0x02` (begin/end session); reads: `0x03`, `0x05`, `0x07`, `0x0a`, `0x1a`, `0x1b`; writes: `0x06`, `0x09`, `0x0b`, `0x12`, `0x15`, `0x17`, `0x21`. `0x1c`, `0x23` and `0xaa` carry no data; one of them is probably a factory reset. **Do not send commands you don't understand.**
- The keyboard does not report charging state.

## AirPods protocol (AAP)

Open an L2CAP `SOCK_SEQPACKET` connection to PSM `0x1001`, then send:

```
00 00 04 00 01 00 02 00 00 00 00 00 00 00 00 00   handshake
04 00 04 00 0f 00 ff ff ff ff                     request notifications
```

Battery reply: `04 00 04 00 04 00 <n>` followed by `n` records `[type] 01 [level] [status] 01`. Types: `04` left, `02` right, `08` case. Status: `01` charging, `02` not charging, `04` disconnected.

## Uninstall

```bash
rm -rf ~/.local/bin/device-batteries ~/.local/share/plasma/plasmoids/org.local.devicebatteries
```

Then remove the widget from the panel (right-click → Remove).
