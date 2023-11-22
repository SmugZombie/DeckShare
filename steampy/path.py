import platform
import os
import vdf
import sys

# 'Linux', 'Darwin', 'Java', 'Windows'
operating_system = platform.system()

if operating_system == ("Linux"):
    steamdir = "/home/deck/.local/share/Steam/"
else:
    sys.exit(f"Cannot handle operating system: {operating_system}")

# get the current steam user's SteamID
def GetSteamId():
    d = vdf.parse(open("{0}config/loginusers.vdf".format(steamdir), encoding="utf-8"))
    users = d['users']
    for id64 in users:
        if users[id64]["MostRecent"] == "1":
            user = int(id64)
            return user

user = GetSteamId()
url = "{0}userdata/{1}/760/remote/".format(steamdir, user & 0xFFFFFFFF)
print(url)