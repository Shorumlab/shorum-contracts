# Shorum Contracts

Shorum Protocol is a nft marketplace driven by web3 social graph.

It forks from lens protocol and extended the following functions:

1. added back follow module which allows the user to pay to back a profile
2. added nft collection as a type of publication
3. allows the user to collect the nft collection and receive a portion of fees
4. etc...

## Setup

> For now only Linux and macOS are known to work
>
> We are now figuring out what works for Windows, instructions will be updated soon
>
> (feel free to experiment and submit PR's)

The environment is built using Docker Compose, note that your `.env` file must have the RPC URL of the network you want to use, and an optional `MNEMONIC` and `BLOCK_EXPLORER_KEY`, defined like so, assuming you choose to use Mumbai network:

```
MNEMONIC="MNEMONIC YOU WANT TO DERIVE WALLETS FROM HERE"
MUMBAI_RPC_URL="YOUR RPC URL HERE"
BLOCK_EXPLORER_KEY="YOUR BLOCK EXPLORER API KEY HERE"
```
