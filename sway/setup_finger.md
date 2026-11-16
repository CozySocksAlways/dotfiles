# Fingerprint Reader Setup — ThinkPad T14 Gen 5 (Arch)

Device: Synaptics `06cb:00f9` (built-in). Supported by stock `libfprint`,
no AUR driver needed.

Check it's present (no `lsusb` installed, so via sysfs):

```bash
grep -l 06cb /sys/bus/usb/devices/*/idVendor
```

## 1. Install

```bash
sudo pacman -S fprintd          # pulls in libfprint
```

If enrolling fails, update the sensor firmware:

```bash
sudo pacman -S fwupd && fwupdmgr refresh && fwupdmgr update
```

## 2. Enroll

```bash
fprintd-enroll                       # right index finger by default
fprintd-enroll -f left-index-finger  # optional extra finger
fprintd-verify                       # test
```

## 3. PAM — swaylock

`/etc/pam.d/swaylock`: add the fprintd line **above** the include:

```
auth sufficient pam_fprintd.so max-tries=1 timeout=10
auth include login
```

- `sufficient` → finger OK unlocks; otherwise falls through to password.
- `max-tries=1 timeout=10` → typing a password only waits ≤10s for the
  finger attempt instead of ~30s.

Usage: lock, press **Enter** on the empty prompt, then touch the sensor
(swaylock only runs PAM after Enter).

How swaylock gets triggered (see `config` / `base.conf`):

- `Super+L` (`Mod4+l`) → `loginctl lock-session` → swayidle `lock` → `swaylock -f`
- also after 5 min idle and before sleep (swayidle)
- note: `$mod` is Alt (`Mod1`); `Alt+L` is focus right, not lock

Escape hatch if it locks you out: `Ctrl+Alt+F2`, log in, `pkill swaylock`.

## Other PAM candidates (not done yet)

Same line at the top of:

- `/etc/pam.d/sudo`
- `/etc/pam.d/system-local-login` (TTY login — won't unlock password-based keyrings)

Avoid `system-auth` (affects su, polkit, everything). Keep a `sudo -i`
shell open while editing PAM files.
