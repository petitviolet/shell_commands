#!/usr/bin/env zsh

# ref: https://qiita.com/arks22/items/7bf7da1433ef9c57b457

tmux_pane_border_string() {
  local current_command=$1
  local pane_pid=$2
  local pane_tty=$3
  local pane_current_path=$4

  local whole_command="$(ps -f | grep $pane_pid | grep $current_command | grep -v grep | awk -F ' ' '{for(i=8;i<NF;++i){printf("%s ",$i)}print $NF}' | tail -n 1 | sed 's/\\n/ /g')"

  local accent_color='bg=black,fg=cyan'
  local directory="$pane_current_path"

  if [[ "$whole_command" =~ "prod" ]]; then
    accent_color='bg=red,fg=black'
  elif [[ "$whole_command" =~ "stage" ]]; then
    accent_color='bg=yellow,fg=black'
  fi

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
    echo "#[$accent_color][$pane_pid]<SSH:$user@$host>#[default]"
  else
    echo "#[$accent_color][$pane_pid]$directory:#[underscore]$whole_command#[default]"
  fi
}

tmux_pane_border_string $*
