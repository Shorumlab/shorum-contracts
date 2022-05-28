import { task } from 'hardhat/config';
import {
  LensHub__factory,
  BackerFeeFollowModule__factory,
  FollowerRewardsDistributor__factory,
  FollowNFT__factory,
} from '../typechain-types';
import { getAddrs, initEnv, waitForTx } from './helpers/utils';

task('distribute-interest', 'create a distributor for a profile id').setAction(
  async ({}, hre) => {
    const [, , user] = await initEnv(hre);
    const addrs = getAddrs();
    const lensHub = LensHub__factory.connect(addrs['lensHub proxy'], user);
    const backerModule = BackerFeeFollowModule__factory.connect(addrs['backer follow module'], user);

    const profileId = 1;

    const distributorAddr = await (await backerModule.getProfileData(profileId)).distributor;
    console.log('distributor address of profile id', profileId, 'is', distributorAddr);

    const wethAddr = '0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa';
    const distributorContract = FollowerRewardsDistributor__factory.connect(distributorAddr, user);
    await waitForTx(distributorContract.addReward(wethAddr, 0));
    console.log('reward added');



    await waitForTx(backerModule.createDistributor(profileId));
    console.log('distributor created');

    const profileData = await backerModule.getProfileData(1);

    console.log('profile data of ', profileId, 'is', profileData);
  }
);
