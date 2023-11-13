#!/bin/bash

set -e

if [[ -n "$NODE_STORE" ]]; then
    chmod 700 "${NODE_STORE}"
    chown -R celestia:celestia "${NODE_STORE}"
    if [[ ! -f ${NODE_STORE}/init ]]; then
      echo "Initializing Celestia Node with command:"
      echo "init" > ${NODE_STORE}/init
      echo "celestia "${NODE_TYPE}" init --p2p.network "${P2P_NETWORK}" --node.store "${NODE_STORE}""
      celestia "${NODE_TYPE}" init --p2p.network "${P2P_NETWORK}" --node.store "${NODE_STORE}"
    fi
else
   chmod 700 /home/celestia
   chown -R celestia:celestia /home/celestia
   if [[ ! -f /home/celestia/init ]]; then
      echo "Initializing Celestia Node with command:"  
      echo "init" > /home/celestia/init
      echo "celestia "${NODE_TYPE}" init --p2p.network "${P2P_NETWORK}""
      celestia "${NODE_TYPE}" init --p2p.network "${P2P_NETWORK}"
    fi
fi


echo ""
echo "Starting Celestia Node...."
celestia $NODE_TYPE start
