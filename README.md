# Shorum Contracts

Shorum Protocol is a nft marketplace driven by web3 social graph.

It forks from lens protocol and extended the following functions:

1. added back follow module which allows the user to pay to back a profile
2. added distributor contract factory to allow the user to createa a distributor contract to distribute the funds to followers as rewards.
3. allows the user to collect the nft collection and receive a portion of fees
4. added more tasks to make it more easy to use
5. etc...

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

## Deploy

To deploy, please execute:

* prepare `.env`
* `npm i`
* `npx hardhat full-deploy-verify --network mumbai`

## Usage

To use the protocol, there are serveral common tasks to be executed. Those scripts can be found under the folder `/tasks`

Please replace the params and network to the target content before executing.

- Unpause

  `npx hardhat unpause --network mumbai`

- Create Profile:

   `npx hardhat create-profile --network mumbai`

- Deploy and verify backer follow module and whitelist it: 

  `deploy-follow-module-and-whitelist --network mumbai`

- Create Distributor: This allows followee to create an address to receive funds to be distributed to followers.
  
  `npx hardhat create-distributor-for-profile --network mumbai`

- Back someone: This allows the user to back a profile with required token amount. (Please approve the target token to the contract first)
  
  `npx hardhat follow-back --network mumbai`


- Set Distributor: set an whitelisted account to send the funds. This is to prevent attack.

- Add Reward: add an allowed reward token

  `npx hardhat add-reward --network mumbai`

- Send and distribute funds:

  `npx hardhat distribute-send-weth --network mumbai`