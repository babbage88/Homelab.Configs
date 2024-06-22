# Show git branch name
force_color_prompt=yes
color_prompt=yes
parse_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
 }
if [ "$color_prompt" = yes ]; then
	PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[01;31m\]$(parse_git_branch)\[\033[00m\]\$ '
 else
 	PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w$(parse_git_branch)\$ '
fi
unset color_prompt force_color_prompt

alias docker='sudo docker'

dockerbash() {
  if [ -z "$1" ]; then
    echo "Usage: dockerbash <container_name>"
  else
    docker exec -it "$1" bash
  fi
}

stageup() {
  if [ -z "$1" ]; then
    docker compose -f ~/projects/WebAPICielos/docker-compose.yaml up -d
  else
    docker compose -f $1 up -d
  fi
}

labup() {
  if [ -z "$1" ]; then
    docker compose -f /plex/docker-compose.yaml up -d
  else
    docker compose -f $1 up -d
  fi
}
