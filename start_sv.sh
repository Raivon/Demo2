#!/bin/bash
setsid ./supervisor.sh $@ >>/opt/supervisor/supervisor.log 2>&1 < /dev/null &
