import { task } from 'hardhat/config';
import { ERC20__factory, LensHub__factory, FollowNFT__factory } from '../typechain-types';
import { getAddrs, initEnv, waitForTx } from './helpers/utils';

task('follow-back', 'follows a profile with back module').setAction(async ({}, hre) => {
  const [, , user] = await initEnv(hre);
  const addrs = getAddrs();
  const lensHub = LensHub__factory.connect(addrs['lensHub proxy'], user);
  const abiCoder = hre.ethers.utils.defaultAbiCoder;
  
  
  // assemble the data, it should be matched with the data when set the module
  const dataStructure = ['address', 'uint256'];
  const currencyAddr = '0xfe4F5145f6e09952a5ba9e956ED0C25e3Fa4c7F1';
  const amount = hre.ethers.BigNumber.from(10).pow(17);
  const data = abiCoder.encode(dataStructure, [currencyAddr, amount]);

  console.log('-- aprove --');
  const currency = ERC20__factory.connect(currencyAddr, user);
  await waitForTx(currency.approve(addrs['backer follow module'], amount));

  console.log('-- follow -- ');
  const profileIdToFollow = 1;
  await waitForTx(lensHub.follow([profileIdToFollow], [data]));
  console.log('followed');

  const followNFTAddr = await lensHub.getFollowNFT(profileIdToFollow);
  const followNFT = FollowNFT__factory.connect(followNFTAddr, user);

  const totalSupply = await followNFT.totalSupply();
  const ownerOf = await followNFT.ownerOf(profileIdToFollow);

  console.log(`Follow NFT total supply (should be 1): ${totalSupply}`);
  console.log(
    `Follow NFT owner of ID 1: ${ownerOf}, user address (should be the same): ${user.address}`
  );
});
