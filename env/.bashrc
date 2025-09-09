# .bashrc

##########################
#### .bashrc ####
##########################

test -f /etc/profile.dos && . /etc/profile.dos


# Some applications read the EDITOR variable to determine your favourite text
# editor. So uncomment the line below and enter the editor of your choice :-)
#export EDITOR=/usr/bin/vim
#export EDITOR=/usr/bin/mcedit


# add aliases if there is a .aliases file
test -s ~/.alias && . ~/.alias


# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

PS1='${PWD#"${PWD%/*/*}/"} \$ '
`export PS1="$(basename $(dirname $PWD))/$(basename $PWD)"`

eval "$(/opt/homebrew/bin/brew shellenv)"
export gfortran=/usr/local/gfortran/bin
export PATH=$PATH:$gfortran
export PATH=$PATH:/opt/R/arm64/bin:/opt/R/arm64/bin/gfortran
export PATH=$PATH:/opt/homebrew:/usr/local/bin:/opt/homebrew/sbin:/opt/homebrew/bin

## Connecting to servers
## For example...
## CU
alias jrcu='ssh USERNAME@XYZLAB.ucdenver.pvt'
## MSU
alias jrmsu='ssh -A USERNAME@compute.cvm.msu.edu -p 55411' #-i ~/.ssh/id_cvmcompute'
alias mhpc='ssh USERNAME@hpcc.msu.edu'

#####################
## General aliases ##
#####################
alias vi='vim'
alias c='clear'
alias e='exit'

alias rm='rm -i'
alias mv='mv -i'
alias ls='ls -lthG --color=auto'
alias ll='ls -lth --color=auto'
alias llh='ls -lthG --color=auto | head'
alias grep='grep --color=auto'

## git
alias gs='git status '
alias ga='git add '
alias gaa='git add -A .'
alias gb='git branch '
alias gc='git commit'
alias gcm='git commit -m'
alias gd='git diff'
alias go='git checkout '
alias gk='gitk --all&'
alias gx='gitx --all'

alias got='git '
alias get='git '


# for vi; rest in .vimrc
set noclobber
set nowrap
set number
set syntax=on
#export CLICOLOR=1

# bind TAB:menu-complete
bind TAB:complete
# bind ESC:complete

## Local (Mac) aliases
alias gh='cd /Users/USERNAME/GitHub'
alias pastweek='find /Users/USERNAME -mtime -7'
alias pastten='find /Users/USERNAME -mtime -10'
alias pastmonth='find /Users/USERNAME -mtime -30'
### Other examples
#alias molevolvr='cd /Users/USERNAME/GitHub/molevolvr'
#alias amr='cd /Users/USERNAME/GitHub/amR'
#alias microgenomer='cd /Users/USERNAME/GitHub/microgenomer'
#alias drugrep='cd /Users/USERNAME/GitHub/drugrep'

#####################
#### MSU compute ####
#####################
# Compute.cvm.msu.edu
alias usermsu='ssh -A USERNAME@compute.cvm.msu.edu -p 55411' #-i ~/.ssh/id_rsa_cvmcompute'

## MSU CVM compute server paths
PATH=$PATH:/bin:/usr/bin:/home
PATH=$PATH:/data/research/XYZLAB:/data/research/XYZLAB/common-data
PATH=$PATH:/data/run/USERNAME:/data/scratch/USERNAME
export PATH

BLASTDB=/data/blastdb
export BLASTDB

BLASTMAT=/opt/software/BLAST/2.2.26/data
export BLASTMAT

INTERPRO=/opt/software/iprscan/5.47.82.0-Python3/data
export INTERPRO

## Server aliases
alias jrlab='cd /data/research/XYZLAB'
alias cdata='cd /data/research/XYZLAB/common_data'
alias shiny='cd /srv/shiny-server'
alias logs='cd /var/log/shiny-server'

#######################
#### e.g., MSU HPC ####
#######################
## MSU HPC PATHS
PATH=/usr/bin:/bin:/usr/sbin:/sbin:/opt/software/:/mnt/research/XYZLAB/software
#/mnt/research/XYZLAB/software/anaconda3/bin:/mnt/research/XYZLAB/software/anaconda3:
PATH=$PATH:/mnt/research/common-data:mnt/research/common-data/Bio:mnt/research/common-data/Bio/blastdb:mnt/research/common-data/Bio/blastdb/v5
PATH=$PATH:/mnt/home/johnj/software/modulefiles
#PATH=$PATH:/mnt/research/XYZLAB/software/sanger-pathogens-Roary-225d24f/bin:/mnt/research/XYZLAB/software/perlmods
export PATH=/usr/local/bin:$PATH
export PATH=/Library/TeX/texbin:$PATH
export PATH

BLASTDB=/opt/software/:/mnt/research/XYZLAB/molevol/data:/mnt/research/common-data:mnt/research/common-data/Bio:mnt/research/common-data/Bio/blastdb:mnt/research/common-data/Bio/blastdb/v5
export BLASTDB

BLASTMAT=/mnt/research/XYZLAB:/mnt/research/XYZLAB/molevol/data:/mnt/research/XYZLAB/evolvr_hpc/data
export BLASTMAT=/mnt/home/USERNAME:/mnt/home/USERNAME/testspace:$BLASTMAT

export PKG_CONFIG_PATH=/usr/local/lib/pkgconfig:/usr/lib/pkgconfig:/opt/X11/lib/pkgconfig

## Google drive download | unused?
function gdrive_download () {
  CONFIRM=$(wget --quiet --save-cookies /tmp/cookies.txt --keep-session-cookies --no-check-certificate "https://docs.google.com/uc?export=download&id=$1" -O- | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1\n/p')
  wget --load-cookies /tmp/cookies.txt "https://docs.google.com/uc?export=download&confirm=$CONFIRM&id=$1" -O $2
  rm -rf /tmp/cookies.txt
}
