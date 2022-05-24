import { task } from 'hardhat/config';
import {
  LensHub__factory,
  BackerFeeFollowModule__factory,
} from '../typechain-types';
import { deployWithVerify, getAddrs, initEnv, waitForTx, ZERO_ADDRESS } from './helpers/utils';

const TREASURY_FEE_BPS = 50;
const LENS_HUB_NFT_NAME = 'Shorum Protocol Profiles';
const LENS_HUB_NFT_SYMBOL = 'SPP';

task('deploy-follow-module-and-whitelist', 'deploy a new follow module and whitelist').setAction(async ({}, hre) => {
  const ethers = hre.ethers;
  const accounts = await ethers.getSigners();
  const deployer = accounts[0];
  const [governance, treasury, user] = await initEnv(hre);
  
  const addrs = getAddrs();
  // const backerFollowModuleAddr = addrs['backer fee follow module'];
  const moduleGlobals = addrs['module globals'];
  const lensHub = LensHub__factory.connect(addrs['lensHub proxy'], governance);

  let deployerNonce = await ethers.provider.getTransactionCount(deployer.address);

  console.log('\n\t-- Deploying Backer Fee Follow Module --');
  const backerFeeFollowModule = await deployWithVerify(
    new BackerFeeFollowModule__factory(deployer).deploy(lensHub.address, moduleGlobals.address, {
      nonce: deployerNonce++,
    }),
    [lensHub.address, moduleGlobals.address],
    'contracts/core/modules/follow/BackerFeeFollowModule.sol:BackerFeeFollowModule'
  );

  console.log('\n\t-- Whitelisting Follow Modules --');
  await waitForTx(lensHub.connect(governance).whitelistFollowModule(backerFeeFollowModule.address, true));
  
});