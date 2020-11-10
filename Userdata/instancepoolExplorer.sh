#!/bin/bash

set -e

if [ -z "$1" ]; then
    echo "Usage: exo-prom-sd.sh TARGETFILE"
    exit 1
fi

TMPFILE=/tmp/$$

echo '[' > $TMPFILE
echo '  {' >>$TMPFILE
echo -n '    "targets": [' >>$TMPFILE

INDEX=0
for instances in $(exo instancepool show autoscaling --output-template "{{ .Instances }}" --output-format json | sed -e 's/\[//' -e 's/\]//'); do
    if [ $INDEX -ne 0 ]; then
        echo -n ',' >>$TMPFILE
    fi
    IP=$(exo vm show pool-075fa-qikui --output-template "{{ .IPAddress }}")
    echo -n "\"${IP}:9100\"" >>$TMPFILE
    let INDEX=${INDEX}+1
done

echo '],' >>$TMPFILE
echo '    "labels": {}' >>$TMPFILE
echo '  }' >>$TMPFILE
echo ']' >>$TMPFILE

mv $TMPFILE $1
