#!/bin/bash

IFACE=$(ip route | awk '/default/ {print $5}')
IP=$(ip -4 addr show $IFACE | grep inet | awk '{print $2}' | cut -d/ -f1)

echo "Current WSL IP address : $IP"