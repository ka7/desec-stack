#!/bin/bash

# wait for api database to come up
host=dbapi; port=3306; n=120; i=0; while ! (echo > /dev/tcp/$host/$port) 2> /dev/null; do [[ $i -eq $n ]] && >&2 echo "$host:$port not up after $n seconds, exiting" && exit 1; echo "waiting for $host:$port to come up"; sleep 1; i=$((i+1)); done

# wait for pdns api to come up
host=nslord; port=8081; n=120; i=0; while ! (echo > /dev/tcp/$host/$port) 2> /dev/null; do [[ $i -eq $n ]] && >&2 echo "$host:$port not up after $n seconds, exiting" && exit 1; echo "waiting for $host:$port to come up"; sleep 1; i=$((i+1)); done

# make sure local settings are available
ls -lh /usr/src/app/desecapi/settings_local.py || exit 1

# migrate database
python manage.py migrate || exit 1

echo Finished migrations, starting API server ...
uwsgi --ini uwsgi.ini
