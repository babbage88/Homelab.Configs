#!/bin/bash
wget https://download.java.net/java/GA/jdk21.0.2/f2283984656d49d69e91c558476027ac/13/GPL/openjdk-21.0.2_linux-x64_bin.tar.gz
tar xvf openjdk-21.0.2_linux-x64_bin.tar.gz

mv jdk-21.0.2/ /usr/local/jdk-21

echo 'export JAVA_HOME=/usr/local/jdk-21' >>/home/jtrahan/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin' >>/home/jtrahan/.bashrc
