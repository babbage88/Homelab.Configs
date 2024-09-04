#!/bin/bash
ssh-keygen -f "/home/jtrahan/.ssh/known_hosts" -R "trahdb1.trahan.dev"
ssh-keygen -f "/home/jtrahan/.ssh/known_hosts" -R "trahdb2.trahan.dev"
ssh-keygen -f "/home/jtrahan/.ssh/known_hosts" -R "trahdb2"
ssh-keygen -f "/home/jtrahan/.ssh/known_hosts" -R "trahdb1"