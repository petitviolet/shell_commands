#!/usr/bin/env zsh
# completion for gradle

# refs: https://gist.github.com/nolanlawson/8694399 : bash-version

# 読み込み中を表示
loading() {
  local count=30
  if [ $# -eq 1 ]; then
    count=$1
  fi
  # INT をtrapして最後の出力を消す
  trap "echo -n '\r                      '; exit 0" INT

  # 改行
  echo
  for i in `seq 1 1 $count`
  do
    echo -n '|\r'  1>&2; sleep 0.05;
    echo -n '/\r'  1>&2; sleep 0.05;
    echo -n '-\r'  1>&2; sleep 0.05;
    echo -n '\\\r' 1>&2; sleep 0.05;
  done
  exit 0
}

# 使用するgradleコマンド
function gradle_command() {
  local gradle_cmd='gradle'
  if [[ -x ./gradlew ]]; then
    gradle_cmd='./gradlew'
  fi
  if [[ -x ../gradlew ]]; then
    gradle_cmd='../gradlew'
  fi
  echo $gradle_cmd
}

# gradleのtask一覧
gradle_tasks() {
  gradle_cmd=$(gradle_command)
  local completions=''
  local cache_dir="$HOME/.gradle_tabcompletion"
  mkdir -p $cache_dir

  local gradle_files_checksum='hoge';
  if [[ -f build.gradle ]]; then # top-level gradle file
    if [[ -x `which md5 2> /dev/null` ]]; then # mac
      local all_gradle_files="$(find . -name build.gradle 2> /dev/null)"
      gradle_files_checksum="$(md5 -q -s "${all_gradle_files}")"
    else # linux
      gradle_files_checksum="$(find . -name build.gradle | xargs md5sum | md5sum)"
    fi
  else
    gradle_files_checksum='no_gradle_files'
  fi

  if [[ -f $cache_dir/$gradle_files_checksum ]]; then # cached! yay!
    completions=$(\cat $cache_dir/$gradle_files_checksum)
  else
    # ジョブ制御を無効化
    set +m
    # バックグラウンドでindicatorを回す
    loading 1000 & >/dev/null 2>&1
    set -m
    # indicatorのprocess id
    local LOADING_PID=$!
    completions=$($gradle_cmd --no-color --quiet tasks --all | grep --color=none ' - ' | awk '{print $1}' | tr '\n' ' ')
    # indicatorを殺す
    kill -INT $LOADING_PID
    if [[ ! -z $completions ]]; then
      echo $completions > $cache_dir/$gradle_files_checksum
    fi
  fi
  echo $completions
}

# pecoでtask選択
function peco-select-gradle-tasks() {
  gradle_cmd=$(gradle_command)
  completions=$(gradle_tasks)
  local selected_task=$(echo ${(o)${(z)completions}} | tr ' ' '\n' | peco)
  if [ -n "$selected_task" ]; then
    BUFFER="$gradle_cmd $selected_task"
    zle accept-line
  fi
  zle clear-screen
}

zle -N peco-select-gradle-tasks
bindkey "^g^t" peco-select-gradle-tasks

# gradleのtag補完
_gradle() {
  local cur="$1"
  completions=$(gradle_tasks)
  local -a commands
  commands=( "${(o)${(z)completions}}" )
  compadd $commands
  return 0;
}

compdef _gradle gradle
compdef _gradle gradlew
compdef _gradle ./gradlew
