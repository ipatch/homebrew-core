this is a branch for installing homebrew formula on archlinux when homebrew is setup in a `~/homebrew` dir instead of the default `/home/linuxbrew` dir.


from my experience `openssl@3` will fail to install on arch due to homebrew not locating the `pod2man` binary

https://github.com/Homebrew/homebrew-core/issues/122061

on my personal computer ie. `rogue` with my homebrew installation in `$HOME/homebrew` i have been having errors when attempting to install `python@3.12` due to the installation not being able to find the `uuid.h` header. from what i understand on linux distros this can be provided by the `util-linux` package. homebrew does provide this package. so modified the `python@3.12.rb` formula file to depend on the `util-linux` package.

for reasons i don't quite understand yet, when i attempt to install `python@3.12` on my arch linux install on my secondary computer _archbox_ i'm getting the below error.

```
/usr/bin/install -c -m 755 Modules/_tkinter.cpython-312-x86_64-linux-gnu.so /home/capin/homebrew/Cellar/python@3.12/3.12.0/lib/python3.12/lib-dynload/_tkinter.cpython-312-x86_64-linux-gnu.so
/usr/bin/install: cannot stat 'Modules/_tkinter.cpython-312-x86_64-linux-gnu.so': No such file or directory
make: *** [Makefile:2084: sharedinstall] Error 1
```

## troubleshooting / archlinux / formula / xz

see my comment below

https://github.com/orgs/Homebrew/discussions/3630#discussioncomment-7558812
