#!/bin/sh

cut_local() {
	grep -vE 'localhost|^0\.|^127\.|^10\.|^172\.16\.|^192\.168\.|^::|^fc..:|^fd..:|^fe..:'
}

until ADDRS=$(dig +short google.com @localhost -p 40500) && [ -n "$ADDRS" ] > /dev/null 2>&1; do sleep 5; done

while read -r line || [ -n "$line" ]; do

  [ -z "$line" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' | cut_local)

  if [ -n "$cidr" ]; then
    ipset -exist add unblocksh "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$range" ]; then
    ipset -exist add unblocksh "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$addr" ]; then
    ipset -exist add unblocksh "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblocksh "$1)}'

done < /opt/etc/unblock/shadowsocks.txt


while read -r line || [ -n "$line" ]; do

  [ -z "$line" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' | cut_local)

  if [ -n "$cidr" ]; then
    ipset -exist add unblockvless "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$range" ]; then
    ipset -exist add unblockvless "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)

  if [ -n "$addr" ]; then
    ipset -exist add unblockvless "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk '{system("ipset -exist add unblockvless "$1)}'

done < /opt/etc/unblock/vless.txt


if ls -d /opt/etc/unblock/vpn-*.txt >/dev/null 2>&1; then
for vpn_file_names in /opt/etc/unblock/vpn-*; do
vpn_file_name=$(echo "$vpn_file_names" | awk -F '/' '{print $5}' | sed 's/.txt//')
unblockvpn=$(echo unblock"$vpn_file_name")
if [ -n '$(ipset list | grep "unblockvpn-")' ] ; then  ipset create "$unblockvpn" hash:net -exist; fi
cat "$vpn_file_names" | while read -r line || [ -n "$line" ]; do
  [ -z "$line" ] && continue
  [ "${line#?}" = "#" ] && continue

  cidr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}' | cut_local)
  if [ -n "$cidr" ]; then
    ipset -exist add "$unblockvpn" "$cidr"
    continue
  fi

  range=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)
  if [ -n "$range" ]; then
    ipset -exist add "$unblockvpn" "$range"
    continue
  fi

  addr=$(echo "$line" | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut_local)
  if [ -n "$addr" ]; then
    ipset -exist add "$unblockvpn" "$addr"
    continue
  fi

  dig +short "$line" @localhost -p 40500 | grep -Eo '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | awk -v unblockvpn="$unblockvpn" '{system("ipset -exist add " unblockvpn " " $1)}'
done
done
fi