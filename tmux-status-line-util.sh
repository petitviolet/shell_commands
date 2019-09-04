#!/usr/bin/env zsh

# ref: https://qiita.com/arks22/items/7bf7da1433ef9c57b457

get_current_command() {
  local current_command=$1
  local pane_pid=$2

  echo "$(ps -f | grep $pane_pid | grep $current_command | grep -v grep | awk -F ' ' '{for(i=8;i<NF;++i){printf("%s ",$i)}print $NF}' | tail -n 1 | sed 's/\\n/ /g')"
}

command_env() {
  local current_command=$1
  local pane_pid=$2

  local whole_command="$(get_current_command $1 $2)"

  # echo "$accent_color pid:$pane_pid current:$current_command whole:$whole_command" >> ~/.log/tmux.log
  if [[ $current_command = "ssh" ]]; then
    info=$({ pgrep -flap $pane_pid ; ps -o command -p $pane_pid; } | xargs -i{} echo {} | awk '/ssh/' | sed -e 's/^[0-9]*[[:blank:]]*ssh //')
    port=$(echo $info | grep -eo '\-p ([0-9]+)'|sed 's/-p //')
    if [ -z $port ]; then
      local port=22
    fi
    info=$(echo $info | sed 's/\-p '"$port"'//g')
    user=$(echo $info | awk '{print $nf}' | cut -f1 -d@)
    host=$(echo $info | awk '{print $nf}' | cut -f2 -d@)

    if [ $user = $host ]; then
      user=$(whoami)
      list=$(awk '
        $1 == "host" {
          gsub("\\\\.", "\\\\.", $2);
          gsub("\\\\*", ".*", $2);
          host = $2;
          next;
        }
        $1 == "user" {
        $1 = "";
          sub( /^[[:space:]]*/, "" );
          printf "%s|%s\n", host, $0;
        }' ~/.ssh/config
      )
      echo $list | while read line; do
        host_user=${line#*|}
        if [[ "$host" =~ $line ]]; then
          user=$host_user
          break
        fi
      done
    fi

    echo "#[bg=blue,fg=black]<SSH:$user@$host>#[default]"
  else
    local accent_color=""
    if [[ "$whole_command" =~ "prod" ]]; then
      echo "#[bg=colour196,fg=white]****PRODUCTION****#[default]"
    elif [[ "$whole_command" =~ "staging" ]]; then
      echo "#[bg=colour154,fg=black]**STAGING**#[default]"
    elif [[ "$whole_command" =~ "localhost" || "$whole_command" =~ "127.0.0.1" ]]; then
      echo "#[bg=default,fg=colour75]LOCAL#[default]"
    elif [[ "$whole_command" =~ "development" ]]; then
      echo "#[bg=colour87,fg=black]DEVELOPMENT#[default]"
    else
      # use default
    fi

  fi
}

cmd=$1
shift
case $cmd in
  'color')
    select_accent_color $*
    ;;
  'command_env')
    command_env $*
    ;;
esac
