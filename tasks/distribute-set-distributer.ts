import { task } from 'hardhat/config';
import {
  LensHub__factory,
  BackerFeeFollowModule__factory,
  FollowerRewardsDistributor__factory,
  FollowNFT__factory,
  ERC20__factory,
} from '../typechain-types';
import { getAddrs, initEnv, waitForTx } from './helpers/utils';

task('distribute-set-distributer', 'set allowed account for distributor contract').setAction(
  async ({}, hre) => {
    const [, , user] = await initEnv(hre);
    const addrs = getAddrs();
    const lensHub = LensHub__factory.connect(addrs['lensHub proxy'], user);
    const backerModule = BackerFeeFollowModule__factory.connect(addrs['backer follow module'], user);

    const profileId = 1;

    const distributorAddr = await (await backerModule.getProfileData(profileId)).distributor;
    console.log('distributor address of profile id', profileId, 'is', distributorAddr);
    const distributorContract = FollowerRewardsDistributor__factory.connect(distributorAddr, user);
    await waitForTx(distributorContract.setRewardsDistributor(user.address, true));
    console.log('setRewardsDistributor', user.address, 'true');
  }
);
