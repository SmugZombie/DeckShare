import steamstuff
steamdir = steamstuff.steamdir
user = steamstuff.GetAccountId()
url = "{0}userdata/{1}/760/remote/".format(steamdir, user & 0xFFFFFFFF)
print(url)