#!/bin/bash
/usr/local/bin/snort -c /etc/snort/snort.conf -d --daq nfq -Q -l /var/log/snort
