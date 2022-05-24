import { task } from 'hardhat/config';
import { LensHub__factory, ModuleGlobals__factory } from '../typechain-types';
import { waitForTx, initEnv, getAddrs, ZERO_ADDRESS } from './helpers/utils';

task('set-follow-module', 'set a follow module for a profile').setAction(async ({}, hre) => {
  const [governance, , user] = await initEnv(hre);
  const addrs = getAddrs();
  const lensHub = LensHub__factory.connect(addrs['lensHub proxy'], governance);
  const moduleGlobals = ModuleGlobals__factory.connect(addrs['module globals'], governance)

  // To be set
  const currencyAddr = '0xfe4F5145f6e09952a5ba9e956ED0C25e3Fa4c7F1';
  const profileId = 1;
  const amountToBePaid = 1e17;
  const moduleAddr = addrs['backer follow module'];
  const dataStructure = ['uint256', 'address', 'address'];

  let governanceNonce = await hre.ethers.provider.getTransactionCount(governance.address);

  // Whitelist the currency
  console.log('\n\t-- Whitelisting Currency in Module Globals --');
  await waitForTx(
    moduleGlobals
      .connect(governance)
      .whitelistCurrency(currencyAddr, true, { nonce: governanceNonce++ })
  );

  console.log('\n\t-- Set Follow Module for Profile --');
  console.log('  Follow Module Addr:', moduleAddr);
  console.log('  Profile Id', profileId);

  const abiCoder = hre.ethers.utils.defaultAbiCoder;
  const data = abiCoder.encode(dataStructure, [amountToBePaid, currencyAddr, user.address]);

  await waitForTx(
    lensHub
      .connect(user)
      .setFollowModule(profileId, moduleAddr, data)
  ); // amount, currency, to

  console.log('Now the follow module is ', await lensHub.getFollowModule(profileId));
});
