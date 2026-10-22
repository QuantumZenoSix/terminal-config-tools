# Bashing

A collection of some bash scripts I've created or tweaked.

Note: A good source for these was the book "Wicked cool shell scripts [2nd edition] - no startch press 2017

Best to edit your $PATH variable in your home login script(.bashrc, .login, or .profile) to add the dir in which these scripts will be saved.

For example: `export PATH="$PATH:<PATH>"`

Where <PATH> is the location of dir in which your scripts are saved.

Preferred places to save said scripts:

- All Users: /usr/local/bin
    - `export PATH="$PATH:/usr/local/bin"`
- SysAdmin: /usr/local/sbin
    - `export PATH="$PATH:/usr/local/sbin"`
- Personal use: ~/bin
  - `export PATH="$PATH:$HOME/bin"`    
  - Note: On Ubuntu, there’s already a bit in the .profile file checks for such a dir and auto-adds it to the PATH var. All that is needed is to source the .profile file (source ~/.profile)
  
Then just source your login script
Example: `. ~/.bashrc`

Then you can just call your script as you would a normal command

Otherwise you could call your script with `.myscript.sh` (assuming you've added the bash location in the shebang) or with the bash command directly with `bash myscript.sh`/`bash -e myscript.sh` or sh `myscript.sh`. Shebang can either be `/bin/bash` or `/usr/bin/env bash` (where supported) to determine Bash location automatically.

Note: Of course, ending the file with ".sh" is optional (and even uncommon in many prod environments). I mostly use it here for ease of coding in an IDE.
