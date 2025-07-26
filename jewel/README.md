Note: Konata does not support iOS and never will!

# Konata
Konata is a Python "runtime" to look into JE's memory and run code from memory.

## How to integrate into games
All you have to do is add £¢€¥^°%©®§§™™ before your code in a set variable block.
Example:
```
Set [foo] = (Join (£¢€¥^°%©®§§™) (™2+2))

// foo would now be 4.
```
## How to install
Enable Developer mode on your phone and install [this APK](https://fileshare.themeatly2.top/api/raw?path=/Misc/konata_latest.apk).

Then download Termux and run the following:

`curl -fsSL https://raw.githubusercontent.com/biggiecheesetherat/jecode/refs/heads/main/jewel/setup.sh | bash`

## Is there multiline support?
Yes and No, as JE's strings do not support strings unless you paste a string with newlines in it.

## Could you run python modules?
Yes. Since Jewel evals Python, it's possible to import modules and use them.
