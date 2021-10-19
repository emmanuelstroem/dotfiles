#
# .zshrc
#
# @author Emmanuel
#
################################################################################
# Prompt
################################################################################
unset LSCOLORS
export CLICOLOR=1
export CLICOLOR_FORCE=1

# Don't require escaping globbing characters in zsh.
unsetopt nomatch

# Nicer prompt.
export PS1=$'\n'"%F{green} %*%F %3~ %F{white}"$'\n'"$ "

# Enable plugins.
plugins=(git brew history kubectl history-substring-search terraform)

# Bash-style time output.
export TIMEFMT=$'\nreal\t%*E\nuser\t%*U\nsys\t%*S'

################################################################################
# Brew
################################################################################
# Tell homebrew to not autoupdate every single time I run it (just once a week).
export HOMEBREW_AUTO_UPDATE_SECS=604800

# Set architecture-specific brew share path.
arch_name="$(uname -m)"
if [ "${arch_name}" = "x86_64" ]; then
  share_path="/usr/local/share"
elif [ "${arch_name}" = "arm64" ]; then
  share_path="/opt/homebrew/share"
else
  echo "Unknown architecture: ${arch_name}"
fi

################################################################################
# Git
################################################################################
# Git upstream branch syncer.
# Usage: gsync master (checks out master, pull upstream, push origin).
function gsync() {
  if [[ ! "$1" ]] ; then
      echo "You must supply a branch."
      return 0
  fi

  BRANCHES=$(git branch --list $1)
  if [ ! "$BRANCHES" ] ; then
      echo "Branch $1 does not exist."
      return 0
  fi

  git checkout "$1" && \
  git pull upstream "$1" && \
  git push origin "$1"
}

################################################################################
# Docker
################################################################################
# Super useful Docker container oneshots.
# Usage: dockrun, or dockrun [centos7|fedora27|debian9|debian8|ubuntu1404|etc.]
dockrun() {
 docker run -it geerlingguy/docker-"${1:-ubuntu1604}"-ansible /bin/bash
}

# Enter a running Docker container.
function denter() {
 if [[ ! "$1" ]] ; then
     echo "You must supply a container ID or name."
     return 0
 fi

 docker exec -it $1 bash
 return 0
}

################################################################################
# OH MY ZSH
################################################################################
export ZSH="$HOME/.oh-my-zsh"

# Set Default User for cleaner shell
DEFAULT_USER=$(whoami)

HOSTNAME='devbox'

DISABLE_AUTO_TITLE="true"

ZSH_THEME="apple"

# Add wisely, as too many plugins slow down shell startup.
plugins=(git kubectl gcloud brew history history-substring-search)

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
export LANG=en_GB.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='mvim'
fi

################################################################################
# Aliases
################################################################################
alias axel="axel -k -n 20"
alias zshconfig="code ~/.zshrc"

# Include alias file (if present) containing aliases for ssh, etc.
if [ -f ~/.aliases ]
then
  source ~/.aliases
fi

################################################################################
# History
################################################################################
# Do NOT add wrong commands to History
zshaddhistory() {
  whence ${${(z)1}[1]} >| /dev/null || return 1
}

# Allow history search via up/down keys.
source ${share_path}/zsh-history-substring-search/zsh-history-substring-search.zsh
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# Ignore Commands from History
HISTORY_IGNORE='([bf]g *|cd *|cd|ls|ls *|l[alsh]#( *)#|tail *|less *|more *||vim# *|axel|axel *|code|code *|exit|pwd|rm *|mv *|cp *|history|history *|mas *|brew *|)'

# Ignore Duplicates
HISTSIZE=10000000
SAVEHIST=10000000

setopt BANG_HIST                 # Treat the '!' character specially during expansion.
setopt EXTENDED_HISTORY          # Write the history file in the ":start:elapsed;command" format.
setopt INC_APPEND_HISTORY        # Write to the history file immediately, not when the shell exits.
setopt SHARE_HISTORY             # Share history between all sessions.
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first when trimming history.
setopt HIST_IGNORE_DUPS          # Don't record an entry that was just recorded again.
setopt HIST_IGNORE_ALL_DUPS      # Delete old recorded entry if new entry is a duplicate.
setopt HIST_FIND_NO_DUPS         # Do not display a line previously found.
setopt HIST_IGNORE_SPACE         # Don't record an entry starting with a space.
setopt HIST_SAVE_NO_DUPS         # Don't write duplicate entries in the history file.
setopt HIST_REDUCE_BLANKS        # Remove superfluous blanks before recording entry.
setopt HIST_VERIFY               # Don't execute immediately upon history expansion.
setopt HIST_BEEP                 # Beep when accessing nonexistent history.

# ZSH History Timestamp format
case ${HIST_STAMPS-} in
  "mm/dd/yyyy") alias history='omz_history -f' ;;
  "dd.mm.yyyy") alias history='omz_history -E' ;;
  "yyyy-mm-dd") alias history='omz_history -i' ;;
  "") alias history='omz_history' ;;
  *) alias history="omz_history -t '$HIST_STAMPS'" ;;
esac

# Completions.
autoload -Uz compinit && compinit
# Case insensitive.
zstyle ':completion:*' matcher-list 'm:{[:lower:][:upper:]}={[:upper:][:lower:]}' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*' 'm:{[:lower:][:upper:]}={[:upper:][:lower:]} l:|=* r:|=*'

################################################################################
# Environment Variables
################################################################################
# The next line adds PATH for the OpenJDK.
export JAVA_HOME="/usr/local/opt/openjdk"
export PATH="$JAVA_HOME/bin:$PATH"

# The next line adds PATH for the Android SDK.
export PATH="$HOME/Library/Android/sdk/tools:$PATH"

# The next line updates PATH for the Google Cloud SDK.
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/path.zsh.inc"
source "$(brew --prefix)/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/completion.zsh.inc"
