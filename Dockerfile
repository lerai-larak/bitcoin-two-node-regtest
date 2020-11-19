FROM ubuntu 

RUN apt-get update && apt-get install -y wget && apt-get -y install gnupg && apt-get update && apt-get install -y iputils-ping && rm -rf /var/lib/apt/lists/*

WORKDIR /bitcoin

RUN wget https://bitcoin.org/bin/bitcoin-core-0.20.1/bitcoin-0.20.1-x86_64-linux-gnu.tar.gz

RUN wget https://bitcoincore.org/bin/bitcoin-core-0.20.1/SHA256SUMS.asc

#Verify that the checksum of the release file (bitcoin-0.20.1-x86_64-linux-gnu.tar.gz)is listed in the checksums file
RUN sha256sum --ignore-missing --check SHA256SUMS.asc

#Obtain a copy of the release signing key
RUN gpg --keyserver hkp://keyserver.ubuntu.com --recv-keys 01EA5486DE18A882D4C2684590C8019E36C2E964

#Verify that the checksums file is PGP signed by the release signing key#
RUN gpg --verify SHA256SUMS.asc

RUN tar xzf bitcoin-0.20.1-x86_64-linux-gnu.tar.gz && install -m 0755 -o root -g root -t /usr/local/bin bitcoin-0.20.1/bin/*

