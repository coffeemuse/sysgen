# Coffee OS (c/OS)

![NETSOL](/screenshots/01_netsol.png)

## What is Coffee OS (c/OS)?

Coffee OS (c/OS) is a mainframe operating system targeting the 24-bit IBM System/370 architecture running under a recent version of the Hercules emulator.

At its core is MVS 3.8j, the public domain operating system from IBM, and ancestor to z/OS. Beyond the core public domain MVS, it integrates many opensource or public domain mods, patches, and components to provide additional or missing functionality.

Using [MVS/CE](https://github.com/MVS-sysgen/sysgen) as a starting point, c/OS various changes to align with my preferences and goals. Re-branding as c/OS exists only to distinguish it from MVS/CE.  

This fork/branch is not intended to compete with MVS/CE. It is my personal fork as I intend to use it for my personal experimentation.  This fork is not officially supported. There are no claims that c/OS is suitable for anything beyond experimentation.   


## Disclaimer
```
THIS SOFTWARE IS PROVIDED “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL ANY CONTRIBUTOR BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
```


To use this version of MVS you can download the current release and run `bash start_mvs.sh`.

Requirements:

- Linux
- Aethra Hercules  >= 4.5 (see below how to build Aethra Hercules.  Note that SDL Hercules should work, but c/OS is only being tested again Aethra)
- python3
- git
- tar

The following is also recommended:

- c3270/x3270
- ncat

## Running

Go to https://github.com/MVS-sysgen/sysgen/releases and download the latest release.
Tagged versions are official releases, latest is automatically built after every
commit. The latest version has all the recent changes and might be unstable. 


## Screenshots

**Wally ISPF with MVS/CE theme**


![ISPF](/screenshots/02_wISPF.png?raw=true "Wally ISPF MVS/CE Theme")

![ISPOPT5](/screenshots/05_UTILITIES.png "Wally ISPF MVS/CE Theme")

![ISPOPT5](/screenshots/03_batch.png "Larry Belmontes Jr ISPOPT5")

![ISPOPT5](/screenshots/06_ISRDDN_DALCDS.png "Larry Belmontes Jr DALCDS")


**MVP**

![MVP](/screenshots/04_MVP.png "MVS Package Manager") 


# Building and Installing Hercules

Please use https://github.com/wrljet/hercules-helper to build hercules

## Sysgen

Currently only Debian/Ubuntu based systems are supported. If your system requires a password for sudo commands you may get prompted for your password to install needed software.

:warning: **DO NOT** run this script as root, there is a bug in hercules which will cause it to eat up all your machine resources :warning:

*depending on your system this could take upward of two hours.* If you want to follow along you can use `tail -F sysgen.log`.

Running MVS/CE sysgen will:

- Build a modified Jay Moseley sysgen MVS 3.8J
- Install BREXX
- Install RAKF
- Install RFE
- Install Wally ISPF
- Create the folder MVSCE and store the completed sysgen there

To build MVS/CE use `sysgen.py`. This python script can take many arguments:

- `--version` This sets the version number displayed at logon and in `SYS1.PARMLIB(RELEASE)`
- `--users` By default sysgen will use the users in the file `users.conf`, you can supply your own with this argument
- `--profiles` By default sysgen will use the RAKF profiles in the file `profiles.conf`, you can supply your own with this argument
- `--username`/`--password` These arguments add an admin user with the username/password supplied
- `--timeout` Sometimes hercules will end up in a state which can deadlock sysgen, to prevent it from running forever a timeout has been set. The defaul it thirty minutes. Use this argument to change it to something shorter/longer, in seconds.
- `--hercules` Path to a specific hercules binary
- `--no-compress` By default this script will compress DASD files, that is not needed on some file systems, this will disable compression
- `--keep-backup` This script backups after every step then removes the backups when completed, if you'd like to keep the backup DASD images use this flag
- `--keep-temp` This script generates multiple temp files during sysgen and removes the folder when completed, if you wish to keep the temp files pass this flag

Assuming you have all the prerequisites installed (git, tar, python3 and
 hercules) the recommended command used to build sysgen is:

```bash
until ./sysgen.py --CONTINUE; do echo "Failed, rerunning"; done
```

This until loop will run until sysgen is complete. This is due to multiple
bugs in hercules which may cause it to fail and which is typically fixed
by rerunning the failed step.

### Automation control options

The arguments below are for more granular control of where to start sysgen from. These can be used if a step has failed of if you make changes to a step and start the install from that step instead of starting over. Some steps are atomic, some have multiple sub steps. With the arguments below you can continue/restart from either.

- `-l` or  `--list` This will list all available steps and substeps.
- `--step` Restart sysgen from this step. The install will continue from here.
- `--substep` Restart sysgen from a steps substep.

- `-C` or `--CONTINUE` If sysgen fails for any reason a file (`.step`) is created prior to exit, this argument reads that file and continues building MVS/CE from where it left off. This superscedes the `--step` and `--substep` arguments.

:warning: By default sysgen will remove the temp and backup folders. If you're doing development work you can use the `--keep-backup` and `--keep-temp` arguments to keep those folders after systen completes allowing you to restart sysgen at any point. 


## Usernames/Passwords

**RAKF**/**TSO**

| Username  | Password |
|:---------:|:--------:|
| IBMUSER   | SYS1     |
| MVSCE01   | CUL8TR   |
| MVSCE02   | PASS4U   |

:warning: *IBMUSER* and *MVSCE01* are RAKF and TSO admins.

You can add a admin user using the `--username` flag. To add more users edit the `users.conf` file.

## Changes From Jay Moseley Sysgen

* Added multiple usermods
* Added RAKF, BREXX, RFE, and ISPF
* Installed usermod `DYNPROC` which allows for dynamic proclibs
* Seperated out usermods to their own JCL for better automation control
* Added `S NET` and changed JES2 startup parms in `sys1.parmlib(COMMND00)`
* Automated startup using HAO hercules
* Adds version to NETSOL
* Added `SYS1.PARMLIB(RELEASE)` which contains release information

And many more. See the branch `original` which tracked changes to the original sysgen and the git log
to see the hundred of other changes since the initial release.

## Info

This repo is heavily based on Jay Moseley sysgen. His writeup is a wonderful resource and you should read the site here: http://www.jaymoseley.com/hercules/installMVS/iMVSintroV7.htm

A lot of the information contained on this repo is directly from his sysgen walkthrough.

There are lots of files and folders. Each folder has a readme explaining from a high level what each file does.

## System Setup Information:

From: http://www.jaymoseley.com/hercules/installMVS/iCUSTv7.htm

Much of the operation of MVS is controlled by JES2 and the parameters that affect JES2 are contained in the member JES2PM00 in SYS1.PARMLIB.  The three main functions are job entry (readers), job execution (job classes), and output (printers and punches).

**Card Readers**

There is one Hercules emulated card reader that is controlled by JES2 - the 2540R at address `x'00c'`. There are other card readers generated into the system and one of those is also defined in the Hercules configuration file - the 2540R at address `x'01c'`.

**Printers**

There are two emulated printers controlled by JES2 - the 1403 at address `x'00e'` and the 3211 at address `x'00f'`. The 1403 printer defined at address `x'015'` is a special case as it defined as, and dedicated to the hardcopy log; it is not controlled by JES2. There are other printers generated into the system, but they are not defined in the configuration file; they are simply 'extra' printers.

**Card Punch**

There is one emulated card punch that is controlled by JES2 - the 2540P at address `x'00d'`.  There are other card punches generated into the system and one of those is also definied in the Hercules configuration file - the 2540P at address `x'01d'`.

**CLASS**

The `CLASS=` parameter on the JOB card determines the class that the job is intended to be run in.

There are six initiators defined to JES2, three are not active when MVS is IPLed, but three of them are automatically started.  The initiators select a job for execution when the `CLASS=` parameter on the JOB card matches one of the CLASSES the initiator is set to process.  Currently the initiators are set to process these classes (listed in order by highest priority first):

| Initiator 1 | Initiator 2 | Initiator 3 | Initiator 4 (not started) | Initiator 5 (not started) | Initiator 6 (not started) |
|:-----------:|:-----------:|:-----------:|:-------------------------:|:-------------------------:|:-------------------------:|
| A           |     B,A     |      S      |         D,C,B,A           |  E,C,B,A                  |   F,E,C,B,A               |


Class **S** is intended for use for System Programming tasks, so some of the control has been loosened on that class, which is why you don't have to 'approve' embedded console commands.  It is not a good idea to simply use S for all of your jobs, however, as there are good reasons for those controls being in place.

The two printers controlled by JES2 are set to select non-held printer output in class **A** (the 1403 at x'00e') and class M (the 3211 at x'00f').

The card punch controlled by JES2 is set to select non-held punch output in class **B**.

Some of the parameters for JES2 may be changed from the MVS console and the changes will only remain in effect until the next IPL.  Some of the parameters must be changed by altering the JES2PM00 member in SYS1.PARMLIB, then stopping and restarting JES2.

