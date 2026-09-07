# Backup guide
Two different things:
* **System images** (automatic) — every update keeps the previous image; Recovery Center can pin any image forever. Undo a bad update.
* **File backups** (Backups / Pika, Recovery Center ▸ *Back up my files*) — Documents, photos, game saves, to an external drive or
  another folder, scheduled. Game saves live in `~/.var/app/com.valvesoftware.Steam` (Steam), `~/Games/Emulation/saves`, and each launcher's
  folder; back up your whole home folder to be safe.
System images do **not** include your files; file backups do **not** restore the system. Do both.
