import { task } from 'hardhat/config';
import {
  LensHub__factory,
  BackerFeeFollowModule__factory,
  FollowerRewardsDistributor__factory,
  FollowNFT__factory,
} from '../typechain-types';
import { getAddrs, initEnv, waitForTx } from './helpers/utils';

task('add-reward', 'add reward').setAction(
  async ({}, hre) => {
    const [, , user] = await initEnv(hre);
    const addrs = getAddrs();
    const lensHub = LensHub__factory.connect(addrs['lensHub proxy'], user);
    const backerModule = BackerFeeFollowModule__factory.connect(addrs['backer follow module'], user);

    const profileId = 1;

    const distributorAddr = await (await backerModule.getProfileData(profileId)).distributor;
    console.log('distributor address of profile id', profileId, 'is', distributorAddr);

    const wethAddr = '0x9c3C9283D3e44854697Cd22D3Faa240Cfb032889';
    const distributorContract = FollowerRewardsDistributor__factory.connect(distributorAddr, user);
    await waitForTx(distributorContract.addReward(wethAddr, 0));
    console.log('reward added');

    const profileData = await backerModule.getProfileData(profileId);
    console.log('profile data of ', profileId, 'is', profileData);
  }
);
