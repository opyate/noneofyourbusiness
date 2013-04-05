![NOYB](http://chart.googleapis.com/chart?cht=qr&chs=150x150&choe=UTF-8&chld=H&chl=http://tiny.cc/noyb)

noneofyourbusiness
==================

Your random ideas kept safe.

Install
=======

    curl -L http://tiny.cc/noyb | sh

The script will then urge you to set up an optional passphrase, which is just for ease of use and means you don't have to enter a passphrase every time you ```save``` or ```resume``` something.

Disclosure
----------

```noyb``` isn't meant to be a secure on-line storage (e.g. poor man's replacement of TrueCrypt + Dropbox). The encryption feature is just meant to deter eyes on work you don't deem quite ready for public consumption yet.

Usage
=====

Are you ever in the middle of a quick bit of work you just started, but you need to scoot, or you get interrupted, but you don't have a minute to set up a new Github repo, push, etc.

Example 1
---------

Just run:

    save /path/to/stuff/you/want/to/keep <optional key>

Resume work on it later with:

	resume <key>

...where ```key``` is the name yourself (or ```noyb```) chose to save the blob as.

Example 2
---------

To save the current directory, but with a specified key, use dot:

	save . aSphincterSaysWhat

...and resume later with:

	resume aSphincterSaysWhat

Example 3
---------

Current directory, no key:

	save

```noyb``` will then choose a random key (e.g. ```533900f1886563664f1c825daf54ab30```. Resume later with:

	resume 533900f1886563664f1c825daf54ab30

FAQ
===

Q: Once resumed, can I ```save``` from the ```work``` directory?
------------------

Sure.

    cd /path/to/noneofyourbusiness/work/MyProject
    # make some changes
    save . MyProject
    
Q: I have ```work``` checked out on 2+ machines. Will work get lost?
------------------

Not as long as you ```resume``` before you start making changes.

    # on machine 1
    cd /path/to/noneofyourbusiness/work/MyProject
    echo "I'm on machine 1" > hello.txt
    save . MyProject
   
    # on machine 2
    resume MyProject
    cd /path/to/noneofyourbusiness/work/MyProject
    echo "I'm on machine 2" >> hello.txt
    save . MyProject
   
    # on machine 1 again
    cd /path/to/noneofyourbusiness/work/MyProject
    cat hello.txt
    # output: I'm on machine 1
    resume MyProject
    cat hello.txt
    # output: I'm on machine 1
    #+ I'm on machine 2
