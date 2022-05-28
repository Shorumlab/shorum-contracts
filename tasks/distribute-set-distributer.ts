import { task } from 'hardhat/config';
import {
  LensHub__factory,
  BackerFeeFollowModule__factory,
  FollowerRewardsDistributor__factory,
  FollowNFT__factory,
  ERC20__factory,
} from '../typechain-types';
import { getAddrs, initEnv, waitForTx } from './helpers/utils';

task('distribute-send-weth', 'send weth to distributor contract and wait for distribute').setAction(
  async ({}, hre) => {
    const [, , user] = await initEnv(hre);
    const addrs = getAddrs();
    const lensHub = LensHub__factory.connect(addrs['lensHub proxy'], user);
    const backerModule = BackerFeeFollowModule__factory.connect(addrs['backer follow module'], user);

    const profileId = 1;

    const distributorAddr = await (await backerModule.getProfileData(profileId)).distributor;
    console.log('distributor address of profile id', profileId, 'is', distributorAddr);

    const wethAddr = '0xA6FA4fB5f76172d178d61B04b0ecd319C5d1C0aa';
    // const weth = ERC20__factory.connect(wethAddr, user);
    // await waitForTx(weth.transfer(distributorAddr, hre.ethers.BigNumber.from(10).pow(18)));

    const distributorContract = FollowerRewardsDistributor__factory.connect(distributorAddr, user);
    const one = hre.ethers.BigNumber.from(10).pow(18);
    await waitForTx(distributorContract.setRewardsDistributor(user.address, true));
    console.log('setRewardsDistributor', user.address, 'true');
  }
);
