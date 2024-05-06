NC='\033[0m' # No Color
RED='\033[0;31m'
GREEN='\033[0;32m'
ORANGE='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYN='\033[0;36m'
LIGHTCYN='\033[1;36m'
LIGHTRED='\033[1;31m'
LIGHTGREEN='\033[1;32m'
YELLOW='\033[1;33m'

printf "${LIGHTCYN} Copying haproxy.cfg file to share swarm volume mount\n"
cp ~/projects/Homelab.Configs/docker/haproxy/haproxy.cfg /mnt/share/gluster/haproxy/haproxy.cfg
printf "${LIGHTRED} File copy complete\n"

printf "${YELLOW} Creating docker swarm haproxy-stack\n ${NC}"
docker stack deploy --compose-file ~/projects/Homelab.Configs/docker/haproxy/haproxy-compose.yaml haproxy-stack
