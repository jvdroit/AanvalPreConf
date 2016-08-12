#!/bin/bash
/usr/bin/mysql <<< $'UPDATE aanvaldb.idsSignatures SET data = REPLACE(data, "alert tcp", "drop tcp");'
/usr/bin/mysql <<< $'UPDATE aanvaldb.idsSignatures SET data = REPLACE(data, "alert (", "drop (");'
/usr/bin/mysql <<< $'UPDATE aanvaldb.idsSignatures SET data = REPLACE(data, "alert udp", "drop udp");'
/usr/bin/mysql <<< $'UPDATE aanvaldb.idsSignatures SET data = REPLACE(data, "alert icmp","drop icmp");'
/usr/bin/mysql <<< $'UPDATE aanvaldb.idsSignatures SET data = REPLACE(data, "alert ip","drop ip");'
