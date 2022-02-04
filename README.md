# autovlan
Created a small script to just make adding a vlan easier for linux.

```bash
Usage: autovlan [-a add/-d delete] [-i interface] [-V vid] [-L address]
Example: ./autovlan.pl -a -i eth1 -v 220
         ./autovlan.pl -a -i eth1 -v 110 -L 10.10.10.0/24
```
