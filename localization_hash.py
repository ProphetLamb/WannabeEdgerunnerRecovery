import mmh3

# Computes the hashes of the localization keys
strings = [
  'Gameplay-Devices-Interactions-Humanity',
  'Mod-Edg-Humanity-Recovery-Amount',
  'Mod-Edg-Humanity-Recovery-Amount-Desc'
]
seed = 4689023
for string in strings:
    print(mmh3.hash(string, seed))

# Result:
# 1535368821
# -825586235
# 1343555316
