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
Both nodes are running on a custom created docker network named `minet` and have their IPs configured as follows:

`node1: 10.0.0.2`

`node2: 10.0.0.3`

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
$ bcrt1qn3vngrv082tnaxu7ek9juty442m2dw5kxzpu8k

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
With the two nodes are connected to each other, `node2` was synched and will aslo show it has 50 blocks in its chain. 
However, if you checked the wallet balance on node1:
`$ bitcoin-cli -regtest -rpcconnect=10.0.0.2 getbalance` you will notice that it reads 0.000. This is because in the `regtest` mode, 100 confirmations are needed to have a reward of 50 bitcoin. So, the coins will be received on the 101 confirmation. Run the `generateblockstoaddress` command again to add another 51 blocks. Now checking the balance should show a reward of 50 bitcoin.


#### Sending 10 bitcoin from node1 to an address created on node2.
Generate an address to receive the coins on node2:
```
$ bitcoin-cli -regtest -rpcconnect=10.0.0.3 getnewaddress
$ bcrt1q2wuhwm3kexxtxk3pk4cx9pk4se49sevsku35xn
```
Send 10 bitcoin to the address:
```
bitcoin-cli -regtest -rpcconnect=10.0.0.2 sendtoaddress bcrt1q2wuhwm3kexxtxk3pk4cx9pk4se49sevsku35xn 10.00

$ f835a338f1a520a3a762c177f0b689e37469a8d17336c7683dc53f31b6790d1f //returned transaction id
```

To see the received coins on node 2:
```
$ bitcoin-cli -regtest -rpcconnect=10.0.0.2 listunspent 0
$ [
  {
    "txid": "f835a338f1a520a3a762c177f0b689e37469a8d17336c7683dc53f31b6790d1f",
    "vout": 0,
    "address": "bcrt1qjykwyy6jdc52h6ne69nqtn0rq8kqx50t39u8v9",
    "label": "",
    "scriptPubKey": "0014912ce213526e28abea79d16605cde301ec0351eb",
    "amount": 10.00000000,
    "confirmations": 0,
    "spendable": true,
    "solvable": true,
    "desc": "wpkh([8ae1d7e7/0'/0'/1']020bb1f87371fc32e4139b075d565b626689d5e378d709ed409e6170843ca77c1a)#s6ypfjmp",
    "safe": false
  }
]
```
Notice that the transaction id (`txid`) is the same as what the `sendtoaddress` command returned.





#### Creating a multisig transaction


