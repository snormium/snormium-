"""Snormium Security Center probes — Fedora Atomic / Bazzite edition. No root needed; failures degrade to UNKNOWN.
Each probe returns (state, title, detail), state in {"ok","warn","bad","unknown"}."""
import os, subprocess, json
OK, WARN, BAD, UNK = "ok", "warn", "bad", "unknown"

def _run(cmd, timeout=10):
    try:
        r = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout); return r.returncode, r.stdout.strip(), r.stderr.strip()
    except (FileNotFoundError, subprocess.TimeoutExpired): return 127, "", ""

def firewall():
    rc, out, _ = _run(["firewall-cmd", "--state"])
    if rc == 127: return UNK, "Firewall", "Couldn't read firewall state."
    if out == "running": return OK, "Firewall", "On. Incoming connections are blocked unless you allow them."
    return BAD, "Firewall", "Off. Your computer accepts incoming connections from the network."

def automatic_updates():
    for t in ("uupd.timer", "ublue-update.timer", "bootc-fetch-apply-updates.timer"):
        if _run(["systemctl", "is-enabled", "--quiet", t])[0] == 0:
            return OK, "Automatic updates", "On. System and app updates install in the background; you choose when to restart."
    return WARN, "Automatic updates", "Off. Turn on to receive security fixes automatically."

def pending_restart():
    rc, out, _ = _run(["rpm-ostree", "status", "--json"], timeout=20)
    if rc != 0: return UNK, "System image", "Couldn't read update status."
    try: staged = any(d.get("staged") for d in json.loads(out)["deployments"])
    except (ValueError, KeyError): return UNK, "System image", "Couldn't read update status."
    if staged: return WARN, "Restart needed", "A system update is ready. It takes effect the next time you restart — no hurry."
    return OK, "System image", "Your system image is current and healthy."

def selinux():
    rc, out, _ = _run(["getenforce"])
    if rc != 0: return UNK, "Application protection", "Couldn't read SELinux state."
    if out == "Enforcing": return OK, "Application protection", "SELinux is enforcing. Apps and services are confined."
    return BAD, "Application protection", f"SELinux is {out}. Apps aren't confined."

def secure_boot():
    if not os.path.isdir("/sys/firmware/efi"): return WARN, "Secure Boot", "Not available: this computer started in legacy BIOS mode."
    rc, out, _ = _run(["mokutil", "--sb-state"])
    if rc != 0: return UNK, "Secure Boot", "Couldn't read Secure Boot state."
    if "enabled" in out.lower(): return OK, "Secure Boot", "On. Only signed boot components can start."
    return WARN, "Secure Boot", "Off. Turn it on in your computer's firmware settings if possible."

def disk_encryption():
    rc, out, _ = _run(["lsblk", "-J", "-o", "NAME,TYPE,MOUNTPOINTS"])
    try: tree = json.loads(out)["blockdevices"]
    except (ValueError, KeyError): return UNK, "Disk encryption", "Couldn't inspect disks."
    def walk(nodes, crypt=False):
        for n in nodes:
            c = crypt or n.get("type") == "crypt"
            if any(m in ("/", "/sysroot") for m in (n.get("mountpoints") or []) if m): return c
            r = walk(n.get("children", []), c)
            if r is not None: return r
        return None
    if walk(tree): return OK, "Disk encryption", "On. Your files are protected if the computer is lost or stolen."
    return WARN, "Disk encryption", "Off. Can only be enabled by reinstalling (tick 'Encrypt my data' in the installer)."

def firmware():
    rc, out, _ = _run(["fwupdmgr", "get-updates", "--json"], timeout=25)
    if rc == 127: return UNK, "Firmware updates", "Firmware updater not installed."
    try: n = len(json.loads(out).get("Devices", [])) if out.strip() else 0
    except ValueError: n = 0
    if n: return WARN, "Firmware updates", f"{n} firmware update(s) available (Security Center > Fix)."
    return OK, "Firmware updates", "Your device firmware is up to date (where supported)."

def rollback_available():
    rc, out, _ = _run(["rpm-ostree", "status", "--json"], timeout=20)
    try: deps = json.loads(out)["deployments"]
    except (ValueError, KeyError): return UNK, "Restore points", "Couldn't read system images."
    if len(deps) >= 2:
        pinned = sum(1 for d in deps if d.get("pinned"))
        return OK, "Restore points", f"{len(deps)} system images kept ({pinned} pinned). Roll back from Recovery Center."
    return WARN, "Restore points", "Only one system image present. After the first update a rollback image will exist."

def screen_lock():
    rc, out, _ = _run(["kreadconfig6", "--file", "kscreenlockerrc", "--group", "Daemon", "--key", "Autolock", "--default", "true"])
    if rc != 0: return UNK, "Screen lock", "Couldn't read screen lock setting."
    if out.strip() == "true": return OK, "Screen lock", "Your screen locks automatically when idle."
    return WARN, "Screen lock", "Screen doesn't lock automatically. Anyone can use your computer while you're away."

def system_health():
    try: st = os.statvfs("/var"); free_pct = st.f_bavail / st.f_blocks * 100
    except OSError: return UNK, "System health", "Couldn't check disk space."
    rc, out, _ = _run(["systemctl", "--failed", "--no-legend", "--plain"])
    failed = [l.split()[0] for l in out.splitlines() if l.strip()] if rc == 0 else []
    if free_pct < 5: return BAD, "System health", f"Only {free_pct:.0f}% disk space left. Updates may fail."
    if failed: return WARN, "System health", f"{len(failed)} background service(s) failed to start: {', '.join(failed[:3])}"
    return OK, "System health", f"{free_pct:.0f}% disk space free, all services running."

PROBES = [firewall, automatic_updates, pending_restart, selinux, secure_boot, disk_encryption, firmware, rollback_available, screen_lock, system_health]
def overall(results):
    s = [r[0] for r in results]
    if BAD in s: return BAD, "Important security action required"
    if WARN in s: return WARN, "Action recommended"
    return OK, "Your computer is protected"
if __name__ == "__main__":
    res = [p() for p in PROBES]; st, msg = overall(res); print(f"[{st.upper()}] {msg}")
    for s, t, d in res: print(f"  {s:8} {t}: {d}")
