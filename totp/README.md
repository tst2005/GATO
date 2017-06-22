
# how to make a standalone totp executable

```sh
(
echo '#!/usr/bin/env python'
wget -q 'https://github.com/tst2005/onetimepass/raw/master/onetimepass/__init__.py' -O -
cat<<EOF
if __name__ == "__main__":
    print("Sample    : %0.6d" % get_totp('MFRGGZDFMZTWQ2LK'))
EOF
) > totp.py
chmod +x totp.py
```


# how to make a encrypted script

```sh
(
cat<<EOF
#!/bin/bash
bin=python2 ; #bin=tail
exec \$bin <(tail -n +\$(grep -hn -- 'BEGIN[ ]PGP[ ]MESSAGE' "\$0" |head -1|cut -d: -f1) "\$0" | gpg -d -q --no-mdc-warning )

#ignored stuff here

EOF
gpg -ca < totp.py
) > totp
chmod +x totp
```
