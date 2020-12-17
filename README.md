## bitcoin-two-node-regtest
This project aims at understanding bitcoin fundamentals by trying the out basic operations in the bitcoin system from the terminal. 

Using docker, it creates two bitcoin nodes which you can connect to from your local machine using bitcoin's RPC interface. With this setup which simulates remote nodes, your locally installed `bitcoin-cli` just connects to the nodes and issues commands. Your local bitcoin installation remains untouched and you can easily drop the docker container holding the nodes and start again from scratch. 

**Warning** this setup is for learning purposes only and therefore uses the `regtest` mode of running bitcoin. It is strongly advised that you do not try carrying out real transactions on using this setup.

The `control_nodes.sh` script file contains functions that allow you to start, stop and remove the nodes.



## Setup
Install [Docker](https://www.docker.com/get-started): The nodes are created as Docker containers and therefore need the environment to run from. To see how they are created, see the `docker-compose.yml` file in the repo.

Install [Bitcoin Core](https://bitcoin.org/en/download) on you local machine: You need a local installation to be able to connect to the 'remote' nodes using the `bitcoin-cli` tool which comes with bitcoin. 

After installation, locate the `bitcoin.conf` file. Normally, this will be in a `.bitcoin` directory inside your `home` directory. (`/home/<yourhomedir>/.bitcoin`). Inside the file, add the athentication credentials that will allow you to connect to the two nodes though RPC.
```
[regtest]
rpcpassword=q7EDoyrwWpBVM1YKKcar6oiPtN5O3XRUPYpN0PYCjTk
rpcauth=user:cc459cb84ea896de7a10b108de879f02$906c2227b3b868d8ac627e85776f0970925c6bf6f67a69c6457c04a82a1fdfc0
  
```

Clone repo to your local machine to start working with the nodes: The `control_nodes.sh` script provides an easy way of managing the nodes.

To start the nodes, from the repo directory, run the command:
```
$ ./control_nodes.sh start

```

To stop the nodes, from the repo directory, run the command:
```
$ ./control_nodes.sh stop

```
## Getting Started

#### Connecting to a node
To send a command to a node you will need to specify the node IP address followed by the command itself. For instance, to get the block chain details on `node1`:

```
$ bitcoin-cli -regtest -rpcconnect=10.0.0.2  getblockchaininfo

```

to get the same details for `node2` simply change the ip address to `10.0.0.3`
# 

#### Mining blocks

Here, we will use `node1` to generate the blocks.

Before generating blocks that will make coins available, we need to get an address where these coins will be sent.
```
$ bitcoin-cli -regtest -rpcconnect=10.0.0.2 getnewaddress
$ **bcrt1qn3vngrv082tnaxu7ek9juty442m2dw5kxzpu8k**

```
Copy the output address for the next command.

Now we generate(mine) 50 blocks and send the block reward coins to our previously created address:
```
bitcoin-cli -regtest -rpcconnect=10.0.0.2 generatetoaddress 50 bcrt1qn3vngrv082tnaxu7ek9juty442m2dw5kxzpu8k

```
Now, if you check the block info on `node1` you will see that it contains 50 blocks
```

$ bitcoin-cli -regtest -rpcconnect=10.0.0.3  getblockchaininfo

```
Also, since the two nodes are connected to each other, `node2` was synched and will aslo show it has 50 blocks in its chain.


#### Generating an address

#### Sending coins to an address

#### Creating a multisig transaction


