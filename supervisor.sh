#!/bin/bash

if [[ $# -eq 0 ]]; then
  echo "supervisor.sh supervisor daemon for service"
  echo "-l (--logfile) - path to logfile for parsing"
  echo "-s (--search_string) - search string"
  echo "-t (--task) - service for restartng"
  echo "-c (--config) - config file for supervisor"
  echo "exmaple: supervisor.sh -l=/var/log/httpd.log -s=Error -t=httpd"
fi

if [[ $# -gt 1 ]] && [[ $# -ne 3 ]]; then
  echo "Wrong parameters count"
  echo "Use -l, -s, -t or only -c parameter"
fi

for i in "$@"; do
  case $i in
  -l=* | --logfile=*)
    logfile="${i#*=}"
    shift
    ;;
  -s=* | --search_string=*)
    search_string="${i#*=}"
    shift
    ;;
  -c=* | --config=*)
    config="${i#*=}"
    shift
    ;;
  -t=* | --task=*)
    task="${i#*=}"
    shift
    ;;
  -* | --*)
    echo "Unknown option $i"
    exit 1
    ;;
  *) ;;

  esac
done

if test -f ${config}; then
  eval $(sed -r '/[^=]+=[^=]+/!d;s/\s+=\s/=/g' "$config")
fi

echo "logfile is $logfile" >>$supervisor_log
echo "search is $search_string" >>$supervisor_log
echo "task is $task" >>$supervisor_log

tail -f -n0 $logfile |
  while read line; do
    line=$(echo $line | grep $search_string)
    if [[ -n $line ]]; then
      echo "Detected" >>$supervisor_log
      systemctl stop "$task.service" >>$supervisor_log
      systemctl start "$task.service" >>$supervisor_log
    fi
  done
