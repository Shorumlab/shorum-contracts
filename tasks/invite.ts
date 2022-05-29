import { task } from 'hardhat/config';
import {
  LensHub__factory,
  BackerFeeFollowModule__factory,
  FollowNFT__factory,
} from '../typechain-types';
import { getAddrs, initEnv, waitForTx } from './helpers/utils';

task('invite', 'invite to follow a profile').setAction(async ({}, hre) => {
  const [, , user] = await initEnv(hre);
  const addrs = getAddrs();
  const lensHub = LensHub__factory.connect(addrs['lensHub proxy'], user);
  const accounts = await hre.ethers.getSigners();
  console.log('user', user.address);

  /// await waitForTx(lensHub.connect(user2).follow([1], [[]]));
  const addressList = [
    '0x86167A5030E1B6af52DDD3464e643Fe2ea3254cA',
    '0xb2c7E667FfD9942bEc79C4b9C0245390732a71df',
    '0xf99CD57209BcBdf015DBb742184Ee157B722cb6e',
  ];
  const profileId = 1;
  await BackerFeeFollowModule__factory.connect(addrs['backer follow module'], user).invite(
    addressList,
    profileId,
    { gasLimit: 5000000 }
  );
  console.log('invited');
  const followNFTAddr = await lensHub.getFollowNFT(1);
  const followNFT = FollowNFT__factory.connect(followNFTAddr, user);

  const totalSupply = await followNFT.totalSupply();
  const ownerOf = await followNFT.ownerOf(1);

  console.log(`Follow NFT total supply (should be 1): ${totalSupply}`);
  console.log(
    `Follow NFT owner of ID 1: ${ownerOf}, user address (should be the same): ${user.address}`
  );
});
