#!/bin/bash
knife encrypt update vault splunk__default --json data_bags/vault/splunk__default.json --search '*:*' --admins 'orpheus,mharris-mbp15' --mode client
