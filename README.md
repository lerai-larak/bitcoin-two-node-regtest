## Docker Based Bitcoin Nodes (A test network of two nodes)
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
$ bitcoin-cli -regtest -rpcconnect=10.0.0.2 generatetoaddress 50 bcrt1qn3vngrv082tnaxu7ek9juty442m2dw5kxzpu8k

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
Notes:
`listunspent` is provided with a argument 0 so that it includes unconfirmed trnsactions (Notice the confirmations property in the output). Otherwise the result would be an empty list. For this transaction to be confirmed, we would need to generate/mine a block that adds it in.
Running `listunspent` on node1 shows that it now has a balance of 39.99997180 bitcoin. Also the `txid` is the same for both outputs since it a reference to the same transaction.

Create 1 block to confirm the above transaction:

```
bitcoin-cli -regtest -rpcconnect=10.0.0.2 generatetoaddress 1 bcrt1qn3vngrv082tnaxu7ek9juty442m2dw5kxzpu8k
```

#### Creating a raw transaction
Using `createrawrtansaction`, you have more control when sending coins to an address, however you would be advised not not use this on the mainnet due to the potential of losing funds.

Create a new address on node2 to receive coins and assign the address to a shell variable as below:
```
RECEIVE_ADDR=$(bitcoin-cli -regtest -rpcconnect=10.0.0.3 getnewaddress)
```
Create a shell variable to hold the change address, this is the sender's address that should receive the balance of (input-output). If this address is not specified, the balance is sent as a fee for the transaction. for instance, if we have 20 bitcoins and specify that we want to send 17 bitcoin without adding our address for the change, the 3 bitcoins will be charged as fee for the transaction.
```
CHANGE_ADDR=$(bitcoin-cli -regtest -rpcconnect=10.0.0.2 getnewaddress)
```

Use `createrawtransaction` from node1 to define a new transaction. Note: the output of this command is the hex representation of the transaction. It has not been signed or broadcasted to the network.

```
$ bitcoin-cli -regtest -rpcconnect=10.0.0.2 createrawtransaction '''[{"txid":"$COINBASE_TR_ID","vout":0}]''' '{"$RECEIVE_ADDR":25.00,"CHANGE_ADDR":23.999}]"
$ 020000000184ce5508c12bd23a197cc898241a28c21541af9d2383
  3aad8b9eb29384cd60190000000000ffffffff0100f90295000000
  00160014f39565de575f67dc0010bed620f99a84174dbb0800000000
  
$ RAW_TX = 020000000184ce5508c12bd23a197cc898241a28c21541af9d23833
           aad8b9eb29384cd60190000000000ffffffff0100f9029500000000
           160014f39565de575f67dc0010bed620f99a84174dbb0800000000 //assign this out transaction hex string to a shell variable for later use.

```
In the above, the transaction will send 25.00 bitcoin to the address a change output is 23.999, the fee will therefore be 0.001. 

Next, sign the transaction.

```
bitcoin-cli -regtest -rpcconnect=10.0.0.2 signrawtransactionwithwallet $RAW_TX
{
  "hex": "0200000000010184ce5508c12bd23a197cc898241a28c21541af9d23833aad8b9eb29384cd60190000000000ffffffff
          0100f9029500000000160014f39565de575f67dc0010bed620f99a84174dbb0802473044022029eaedd63cf776d93ff9
          b58d4ebd7aa13b8bbf82e6816818e6e680f911e1d97402207da1820a566dd8b37702a8a653c23d381a89c4f21bcfd26f
          3588d1d05080978601210266f7a6856c5cc7fad9a398adfc9852ca238c38a0504810e6b6491112b277307600000000",
  "complete": true
}

//assing the above singned transaction hex to a shell variable
SIGNED_TX = 0200000000010184ce5508c12bd...
```

Now send the transaction.
```
bitcoin-cli -regtest -rpcconnect=10.0.0.2 sendrawtransaction $SIGNED_TX
```

#### Creating a multisig transaction

In general, a multisig transaction means that funds are sent to multiple addresses and, subsequently, each of the owners of the receiving addresses have to sign a the spending transaction to reuse the funds. In technical terms it is a way that allows more than one person to create a digital signature. Multisig transactions are described as m-of-n in that, out of a possible n singnatures m can be used to unlock the funds. (where m < n).

To create the multisig transaction, we first need to create a multisig address. For that, we need the addresses of the recepients (in this case, we create a 2-of-2 multisig address)

##### Get the addresses to be used 

```
$address1=bitcoin-cli -regtest -rpcconnect=10.0.0.2 getnewaddress
$address2=bitcoin-cli -regtest -rpcconnect=10.0.0.3 getnewaddress
```
To create the multisig address, we need the public keys contained in these addresses.

```
$ bitcoin-cli -regtest -rpcconnect=10.0.0.2 getaddressinfo $address1
{
  "address": "bcrt1qc0at6drw9zhn6jd573qzm68yffr53j0nldacds",
  "scriptPubKey": "0014c3fabd346e28af3d49b4f4402de8e44a4748c9f3",
  "ismine": true,
  "solvable": true,
  "desc": "wpkh([0346d5c9/0'/0'/5']03449f7c5140f23a7b34d1d1628265cc7bdbe133f4fcd0f08f6079414fb2c29b52)#3vjan8dd",
  "iswatchonly": false,
  "isscript": false,
  "iswitness": true,
  "witness_version": 0,
  "witness_program": "c3fabd346e28af3d49b4f4402de8e44a4748c9f3",
  "pubkey": "03449f7c5140f23a7b34d1d1628265cc7bdbe133f4fcd0f08f6079414fb2c29b52",
  "ischange": false,
  "timestamp": 1608153032,
  "hdkeypath": "m/0'/0'/5'",
  "hdseedid": "d4a5703c7058842f72e4e4a2be053be419573bab",
  "hdmasterfingerprint": "0346d5c9",
  "labels": [
    ""
  ]
}

$ bitcoin-cli -regtest -rpcconnect=10.0.0.3 getaddressinfo $address2
{
  "address": "bcrt1qfsaahunga9h9ez3a9cp44u05cpz7gwq4rx2gnm",
  "scriptPubKey": "00144c3bdbf268e96e5c8a3d2e035af1f4c045e43815",
  "ismine": true,
  "solvable": true,
  "desc": "wpkh([8ae1d7e7/0'/0'/3']02e42161dd6623b4d12083c1c2e21d75f3abd57448470599493329d53d8e02b6d8)#zkurn8j3",
  "iswatchonly": false,
  "isscript": false,
  "iswitness": true,
  "witness_version": 0,
  "witness_program": "4c3bdbf268e96e5c8a3d2e035af1f4c045e43815",
  "pubkey": "02e42161dd6623b4d12083c1c2e21d75f3abd57448470599493329d53d8e02b6d8",
  "ischange": false,
  "timestamp": 1608152258,
  "hdkeypath": "m/0'/0'/3'",
  "hdseedid": "0baa00630c55e2dbe79c2faf7b3c0f05d550c9a3",
  "hdmasterfingerprint": "8ae1d7e7",
  "labels": [
    ""
  ]
}
