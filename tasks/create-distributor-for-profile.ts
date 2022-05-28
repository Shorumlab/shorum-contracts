import { task } from 'hardhat/config';
import { LensHub__factory, BackerFeeFollowModule__factory, FollowNFT__factory } from '../typechain-types';
import { getAddrs, initEnv, waitForTx } from './helpers/utils';

task('create-distributor-for-profile', 'create a distributor for a profile id').setAction(
  async ({}, hre) => {
    const [, , user] = await initEnv(hre);
    const addrs = getAddrs();
    const lensHub = LensHub__factory.connect(addrs['lensHub proxy'], user);
    const backerModule = BackerFeeFollowModule__factory.connect(
      addrs['backer follow module'],
      user
    );

    const profileId = 1;

    await waitForTx(backerModule.createDistributor(profileId));
    console.log('distributor created');

    const profileData = await backerModule.getProfileData(1);

    console.log('profile data of ', profileId, 'is', profileData);
  }
);
