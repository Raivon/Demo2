#!/bin/bash
kill -9 $(cat /var/run/supervisor-$1.pid)
