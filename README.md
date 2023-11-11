this is a branch for installing homebrew formula on archlinux when homebrew is setup in a `~/homebrew` dir instead of the default `/home/linuxbrew` dir.


from my experience `openssl@3` will fail to install on arch due to homebrew not locating the `pod2man` binary

https://github.com/Homebrew/homebrew-core/issues/122061

on my personal computer ie. `rogue` with my homebrew installation in `$HOME/homebrew` i have been having errors when attempting to install `python@3.12` due to the installation not being able to find the `uuid.h` header. from what i understand on linux distros this can be provided by the `util-linux` package. homebrew does provide this package. so modified the `python@3.12.rb` formula file to depend on the `util-linux` package.
