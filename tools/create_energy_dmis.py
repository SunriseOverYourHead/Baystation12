#!/usr/bin/env python3
"""
Creates all missing per-gun DMI files for energy guns.
Run from the repo root directory.
"""

import os
import sys
import shutil

# Add tools dir to path for dmi_tool
sys.path.insert(0, os.path.join(os.path.dirname(__file__)))
from dmi_tool import load_dmi, save_dmi, _state_tiles

BASE = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
OLD_ICONS = os.path.join(BASE, "icons", "obj", "guns")
NEW_BASE = os.path.join(BASE, "icons", "obj", "guns", "energy")


def ensure_dir(path):
    os.makedirs(os.path.dirname(path), exist_ok=True)


def copy_dmi(src_name, dst_rel):
    src = os.path.join(OLD_ICONS, src_name)
    dst = os.path.join(NEW_BASE, dst_rel)
    ensure_dir(dst)
    if not os.path.exists(src):
        print(f"  MISSING source: {src_name}")
        return
    shutil.copy2(src, dst)
    print(f"  Copied {src_name} -> energy/{dst_rel}")


def extract_dmi(src_name, dst_rel, state_names):
    """Extract specific states from source DMI into a new DMI."""
    src = os.path.join(OLD_ICONS, src_name)
    dst = os.path.join(NEW_BASE, dst_rel)
    ensure_dir(dst)
    if not os.path.exists(src):
        print(f"  MISSING source: {src_name}")
        return

    w, h, all_states, img = load_dmi(src)
    out_states = []
    out_tiles = []
    for i, s in enumerate(all_states):
        if s['name'] in state_names or state_names == '*':
            out_states.append(s)
            out_tiles.append(_state_tiles(img, w, h, all_states, i))

    save_dmi(dst, w, h, out_states, out_tiles)
    names = [s['name'] for s in out_states]
    print(f"  Extracted {len(out_states)} states from {src_name} -> energy/{dst_rel}: {names}")


print("=== Creating energy gun DMI files ===\n")

# --- laser gun family ---
# laser.dmi: laser, practice, secure, xenofauna variants all in laser_carbine.dmi
extract_dmi("laser_carbine.dmi", "laser/laser.dmi",
            {"", "laser", "laser100", "laser75", "laser50", "laser25", "laser0"})
extract_dmi("laser_carbine.dmi", "laser_secure/laser_secure.dmi",
            {"lasersec", "lasersec100", "lasersec75", "lasersec50", "lasersec25", "lasersec0"})
extract_dmi("laser_carbine.dmi", "xenofauna/xenofauna.dmi",
            {"laserwild", "laserwild100", "laserwild75", "laserwild50", "laserwild25", "laserwild0"})
# laserp states for practice subtype (stays in laser folder)
extract_dmi("laser_carbine.dmi", "laser/practice.dmi",
            {"laserp", "laserp100", "laserp75", "laserp50", "laserp25", "laserp0"})

copy_dmi("retro_laser.dmi", "retro/retro.dmi")
copy_dmi("caplaser.dmi", "captain/captain.dmi")
copy_dmi("laser_cannon.dmi", "lasercannon/lasercannon.dmi")
copy_dmi("lasertag.dmi", "lasertag/lasertag.dmi")

# --- x-ray gun family ---
copy_dmi("xray.dmi", "xray/xray.dmi")
copy_dmi("xray_pistol.dmi", "xray/xray_pistol.dmi")
copy_dmi("laser_sniper.dmi", "sniperrifle/sniperrifle.dmi")

# --- energy gun family ---
copy_dmi("energy_gun.dmi", "gun/gun.dmi")
copy_dmi("skrell_pistol.dmi", "gun/gun_skrell.dmi")
copy_dmi("small_egun.dmi", "gun/gun_small.dmi")
copy_dmi("adv_egun.dmi", "gun_nuclear/gun_nuclear.dmi")

# --- taser family ---
copy_dmi("taser.dmi", "taser/taser.dmi")
copy_dmi("taser_carbine.dmi", "taser_carbine/taser_carbine.dmi")

# --- stun revolver family ---
copy_dmi("stunrevolver.dmi", "stunrevolver/stunrevolver.dmi")
copy_dmi("stunrifle.dmi", "stunrevolver/stunrifle.dmi")

# --- energy crossbow ---
copy_dmi("energy_crossbow.dmi", "crossbow/crossbow.dmi")

# --- stun/special guns ---
copy_dmi("plasma_stun.dmi", "plasmastun/plasmastun.dmi")
copy_dmi("confuseray.dmi", "confuseray/confuseray.dmi")

# --- ion guns ---
copy_dmi("ion_rifle.dmi", "ionrifle/ionrifle.dmi")
copy_dmi("ion_pistol.dmi", "ionrifle/ionrifle_small.dmi")

# --- special energy guns ---
copy_dmi("decloner.dmi", "decloner/decloner.dmi")
copy_dmi("floral.dmi", "floragun/floragun.dmi")
copy_dmi("toxgun.dmi", "toxgun/toxgun.dmi")
copy_dmi("plasmacutter.dmi", "plasmacutter/plasmacutter.dmi")
copy_dmi("incendiary_laser.dmi", "incendiary_laser/incendiary_laser.dmi")

# --- meteor gun: needs just "riotgun" state from launchers.dmi ---
extract_dmi("launchers.dmi", "meteorgun/meteorgun.dmi", {"riotgun"})

# --- mind flayer: uses "xray" state from xray.dmi ---
extract_dmi("xray.dmi", "mindflayer/mindflayer.dmi", {"xray"})

# --- vox guns ---
copy_dmi("darkcannon.dmi", "darkmatter/darkmatter.dmi")
copy_dmi("noise.dmi", "sonic/sonic.dmi")

# --- staves ---
copy_dmi("staff.dmi", "staff/staff.dmi")

# --- mantid particle lance ---
copy_dmi("particle_rifle.dmi", "particle/particle.dmi")

# --- secure energy guns ---
copy_dmi("small_egun_secure.dmi", "gun_small_secure/gun_small_secure.dmi")
copy_dmi("stunrevolver_secure.dmi", "stunrevolver_secure/stunrevolver_secure.dmi")
copy_dmi("energy_gun_secure.dmi", "gun_secure/gun_secure.dmi")
copy_dmi("energy_revolver.dmi", "revolver/revolver_secure.dmi")

# Also need the energy revolver base for the revolver folder
copy_dmi("energy_revolver.dmi", "revolver/revolver.dmi")

# --- pulse family ---
copy_dmi("pulse_rifle.dmi", "pulse_rifle/pulse_rifle.dmi")
copy_dmi("pulse_carbine.dmi", "pulse_rifle/pulse_carbine.dmi")
copy_dmi("pulse_pistol.dmi", "pulse_rifle/pulse_pistol.dmi")
copy_dmi("skrell_carbine.dmi", "pulse_rifle/skrell_carbine.dmi")

print("\n=== Done creating energy gun DMI files ===")
