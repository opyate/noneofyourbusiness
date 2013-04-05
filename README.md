![NOYB](http://chart.googleapis.com/chart?cht=qr&chs=150x150&choe=UTF-8&chld=H&chl=http://tiny.cc/noyb)

noneofyourbusiness
==================

Your random ideas kept safe.

Install
=======

    curl -L http://tiny.cc/noyb | sh

The script will then prompt you for an optional passphrase, which is just for ease of use and means you don't have to enter a passphrase every time you ```save``` something.

Disclosure
----------

```noyb``` isn't meant to be a poor man's replacement of hardened apps like 1Password, etc. The encryption feature is just meant to deter eyes on work you don't deem quite ready for public consumption yet.

Usage
=====

Are you ever in the middle of a quick bit of work you just started, but you need to scoot, or you get interrupted, but you don't have a minute to set up a new Github repo, push, etc.

Just run:

    save /path/to/stuff/you/want/to/keep

Resume work on it later with:

	resume <key>

...where ```key``` is the name yourself (or ```noyb```) chose to save the blob as.


