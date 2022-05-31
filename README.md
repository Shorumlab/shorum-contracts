# Shorum Contracts

Shorum Protocol is a nft marketplace driven by web3 social graph.

It forks from `lens protocol` and extended the following functions:

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
* `npx hardhat testnet-full-deploy-verify --network mumbai`

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

  `npx hardhat distribute-set-distributer --network mumbai`

- Add Reward: add an allowed reward token

  `npx hardhat add-reward --network mumbai`

- Send and distribute funds:

  `npx hardhat distribute-send-weth --network mumbai`
## Deployed Contract

Deployed in mumbai for testing purpose.

```json
{
  "lensHub proxy": "0x0f6c67F2b78a231d6920b8825C6bdb1A4B715Df7",
  "lensHub impl:": "0x778bF0cAf6C5bd7EfA3D439C4a36E58fdC1Df8FA",
  "publishing logic lib": "0xe6e3A507f0Cb11F367a6490414c43D94b4261A37",
  "interaction logic lib": "0x25BADEF6517b2Bf2d342f1ae95689a84d78d74c2",
  "profile token URI logic lib": "0x2842007fF7cc95B34F2e0C722b082bE56f138bba",
  "follow NFT impl": "0x38f9fa9a77bd1ede5c41b8b3b2ab30b3c7bdcb5c",
  "collect NFT impl": "0x35b71bf186c94d264264c5a6e6a75467cb9494ff",
  "lens periphery": "0xb3f17b6C7453AcDb4aC449AFE0a066C4dCC82f4b",
  "module globals": "0x5F044a4ACb91afaf6A1136C51d01318a75C01902",
  "fee collect module": "0xfD0f2192536Bc516eb5Ef5EAAc3073820e706b3b",
  "free collect module": "0x99Fa14b225a9fC5AE22e1fEE04e8ED76725Fd762",
  "fee follow module": "0x5b172513DCf2c39cfC81c361768D82aEB127633E",
  "backer follow module": "0xf2613a453b266a67D02C81d8c920c64a90257206",
  "follower only reference module": "0x4B04F55c5072c5109424aba622694781F4fE421a",
  "profile creation proxy": "0x58cBBcfdAD30B07d0FD70312980Aad43dE7B7010",
  "UI data provider": "0x17426a1695ad4aF79CF98102Aa063e4440d4Ca91"
}
```

Deployed in polygon mainnet:

```json
{
  "lensHub proxy": "0xf3Fce0c9C3120Ee3b5742f18Fcd0EdD9cF08228F",
  "lensHub impl:": "0x97a7B1b231B9Dbb6686Fee6D94Bb69885e1fFD9F",
  "publishing logic lib": "0xC72083E3e4Ee14afdd8A9049aA5235008227E4f6",
  "interaction logic lib": "0x9D09aA57A5F34d19627594aF495C8edAE921F201",
  "profile token URI logic lib": "0x569A3Efc003f624980AA7dB3cc164c8366D5172f",
  "follow NFT impl": "0xd6581f2bc52b81139ea77a7cb371e37c64a13e5a",
  "collect NFT impl": "0x7e19969bc6408819de5a703bb0622fe9e155c34c",
  "lens periphery": "0xA60D8a5E653592383B373163665b5B85Ad99CD16",
  "module globals": "0x7b94a15d76d870FB4AeA233E98f6367C5A4DAA2c",
  "fee collect module": "0x86a4Cf08f5145458eC42b3933AB4C57e1AfC80f1",
  "fee follow module": "0x05D2b432B2e7890d78ea7aC5EF7c6009b002C612",
  "backer follow module": "0xE19122416BeeD4cbaDd663878de9af7c0eb32368",
  "UI data provider": "0xE8E2F01A2b06e3483140110e683c6945010225aB",
  "Profile creation proxy": "0xd2aD99FbB9835Ec17B546292b1c186866f6bfeb2"
}
```

## Frontend integration

write

* create-profile
  - create-profile
  - set backer follow module
  
* follow
  * approve
  * follow-back

* distribute follow rewards
  * display address
    * get profile data

* claim-rewards
  * distributor - claim-rewards

* lensHub
* Backer Follow Module
* Distributor



