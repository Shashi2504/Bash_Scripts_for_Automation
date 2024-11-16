#!/bin/bash

sudo apt update

sudo apt upgrade -y

sudo apt autoremove -y

sudo apt clean

echo "System update completed"
