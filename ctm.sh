#!/bin/bash
echo "                            "
echo " Reset PPPOe Connection !!! "
echo "                            "
dhclient -r -v
dhclient -v