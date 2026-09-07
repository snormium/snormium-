# Recovery guide — "Something went wrong"
Every update keeps the previous system image. That is the whole recovery story: nothing is ever overwritten in place.
**Misbehaves after an update** → Recovery Center ▸ *Undo the last update* ▸ restart. Or at the boot menu, pick the older entry.
**Want a permanent restore point** → Recovery Center ▸ *Pin current image*.
**"Update failed"** → Recovery Center ▸ *Repair updates*. Your files are untouched.
**Nothing boots** → boot the install USB, choose *Rescue*; or reinstall — the installer can keep `/home` if you chose a separate
partition. Files backed up with Backups (Pika) restore from any external drive.
**Forgot password** → boot menu ▸ press `e` on the entry ▸ add `rd.break` ▸ Ctrl+X ▸ `chroot /sysroot; passwd <user>`. (Encrypted
disks need the disk passphrase first.)
