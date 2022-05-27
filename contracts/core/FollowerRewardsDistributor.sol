// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";


contract FollowerRewardsDistributor is ReentrancyGuard, Ownable, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;
    // binded profile id
    uint256 profileId;
    address followNFT;

    struct RewardData {
        address rewardsDistributor;
        uint256 rewardsDuration;
        uint256 periodFinish;
        uint256 rewardRate;
        uint256 lastUpdateTime;
        uint256 rewardPerNFTStored;
    }

    mapping(address => RewardData) rewardData; // rewardToken => rewardData
    address[] public rewardTokens;
    uint256 totalRegistered;
    
    mapping(address => uint256) userRegisteredAmount; // user address => user registered nft amount
    
    mapping(address => mapping(address => uint256)) public userRewardPerTokenPaid;
    mapping(address => mapping(address => uint256)) public userRewardPerTokenEarned;

    constructor(uint256 _profileId, address _followNFT) {
        profileId = _profileId;
        followNFT = _followNFT;
        totalRegistered = 0;
    }

    function addReward(address _rewardToken, address _rewardsDistributor, uint256 _rewardsDuration) external onlyOwner {
        require(rewardData[_rewardToken].rewardsDuration == 0);
        rewardTokens.push(_rewardToken);
        rewardData[_rewardToken].rewardsDistributor = _rewardsDistributor;
        rewardData[_rewardToken].rewardsDuration = _rewardsDuration;
        rewardData[_rewardToken].rewardPerNFTStored = 0;
    }

    function setRewardsDistributor(address _rewardToken, address _rewardsDistributor) external onlyOwner {
        rewardData[_rewardToken].rewardsDistributor = _rewardsDistributor;
    }

    // function totalRegistered() external view returns (uint256) {
    //     return totalRegistered;
    // }

    // function registeredOf(address account) external view returns (uint256) {
    //     return userRegisteredAmount[account];
    // }

    function getRewardPerNFTEarned(address _rewardToken) public view returns (uint256) {
        if (totalRegistered == 0) {
            return rewardData[_rewardToken].rewardPerNFTStored;
        }
        return
            rewardData[_rewardToken].rewardPerNFTStored.add(
                lastTimeRewardApplicable(_rewardToken).sub(rewardData[_rewardToken].lastUpdateTime).mul(rewardData[_rewardToken].rewardRate).mul(1e18).div(totalRegistered)
            );
    }

    // should be invoked when the followNFT is minted
    function register(address _user, uint256 _tokenId) external nonReentrant updateReward(_user) {
        require(_tokenId >= 0, "invalid-token-id");
        totalRegistered = totalRegistered.add(1);
        userRegisteredAmount[_user] = userRegisteredAmount[_user].add(1);
        // Todo:: verify if the user hold this nft

        // emit Registered(_user, _tokenId);
    }

    // should be invoked when the followNFT is burned or blacklisted
    function unregister(address _user, uint256 _tokenId) public nonReentrant updateReward(_user) {
        // require(amount > 0, "Cannot withdraw 0");
        totalRegistered = totalRegistered.sub(1);
        userRegisteredAmount[msg.sender] = userRegisteredAmount[msg.sender].sub(1); //todi:: verify if it will be less than 0
        // Todo:: verify no other user hold this nft

        // emit UnRegsitered(_user, _tokenId);
    }

    function claimReward(address _user, address _rewardToken) public nonReentrant updateReward(_user) {
        require(userRewardPerTokenEarned[msg.sender][_rewardToken] > 0, 'no-claimable-reward');
        uint256 reward = userRewardPerTokenEarned[msg.sender][_rewardToken];
        if (reward > 0) {
            userRewardPerTokenEarned[msg.sender][_rewardToken] = 0;
            IERC20(_rewardToken).safeTransfer(_user, reward);
            // emit RewardPaid(_user, _rewardsToken, reward);
        }
    }

    function claimAllRewards(address _user) public nonReentrant updateReward(_user) {
        for (uint i; i < rewardTokens.length; i++) {
            address _rewardsToken = rewardTokens[i];
            uint256 reward = userRewardPerTokenEarned[msg.sender][_rewardsToken];
            if (reward > 0) {
                userRewardPerTokenEarned[msg.sender][_rewardsToken] = 0;
                IERC20(_rewardsToken).safeTransfer(_user, reward);
                // emit RewardPaid(msg.sender, _rewardsToken, reward);
            }
        }
    }

    function notifyRewardAmount(address _rewardsToken, uint256 reward) external updateReward(address(0)) {

        // 
        // rewardData[rewardToken]
        // Todo:: only allow whitelist to prevent attack
        // require(rewardData[_rewardsToken].rewardsDistributor == msg.sender);
        // handle the transfer of reward tokens via `transferFrom` to reduce the number
        // of transactions required and ensure correctness of the reward amount
        IERC20(_rewardsToken).safeTransferFrom(msg.sender, address(this), reward);

        if (block.timestamp >= rewardData[_rewardsToken].periodFinish) {
            rewardData[_rewardsToken].rewardRate = reward.div(rewardData[_rewardsToken].rewardsDuration);
        } else {
            uint256 remaining = rewardData[_rewardsToken].periodFinish.sub(block.timestamp);
            uint256 leftover = remaining.mul(rewardData[_rewardsToken].rewardRate);
            rewardData[_rewardsToken].rewardRate = reward.add(leftover).div(rewardData[_rewardsToken].rewardsDuration);
        }
        
        rewardData[_rewardsToken].lastUpdateTime = block.timestamp;
        rewardData[_rewardsToken].periodFinish = block.timestamp.add(rewardData[_rewardsToken].rewardsDuration);
        // emit RewardAdded(reward);
    }

    function setRewardsDuration(address _rewardsToken, uint256 _rewardsDuration) external {
        require(
            block.timestamp > rewardData[_rewardsToken].periodFinish,
            "Reward period still active"
        );
        require(rewardData[_rewardsToken].rewardsDistributor == msg.sender);
        require(_rewardsDuration > 0, "Reward duration must be non-zero");
        rewardData[_rewardsToken].rewardsDuration = _rewardsDuration;
        // emit RewardsDurationUpdated(_rewardsToken, rewardData[_rewardsToken].rewardsDuration);
    }

    function rewardPerToken(address _rewardsToken) public view returns (uint256) {
        if (totalRegistered == 0) {
            return rewardData[_rewardsToken].rewardPerNFTStored;
        }
        return
            rewardData[_rewardsToken].rewardPerNFTStored.add(
                lastTimeRewardApplicable(_rewardsToken).sub(rewardData[_rewardsToken].lastUpdateTime).mul(rewardData[_rewardsToken].rewardRate).mul(1e18).div(totalRegistered)
            );
    }

    function earned(address account, address _rewardsToken) public view returns (uint256) {
        return userRegisteredAmount[account].mul(rewardPerToken(_rewardsToken).sub(userRewardPerTokenPaid[account][_rewardsToken])).div(1e18).add(userRewardPerTokenEarned[account][_rewardsToken]);
    }

    function lastTimeRewardApplicable(address _rewardsToken) public view returns (uint256) {
        return Math.min(block.timestamp, rewardData[_rewardsToken].periodFinish);
    }

    /* ========== MODIFIERS ========== */
    modifier updateReward(address account) {
        for (uint i; i < rewardTokens.length; i++) {
            address token = rewardTokens[i];
            rewardData[token].rewardPerNFTStored = rewardPerToken(token);
            rewardData[token].lastUpdateTime = lastTimeRewardApplicable(token);
            if (account != address(0)) {
                userRewardPerTokenEarned[account][token] = earned(account, token);
                userRewardPerTokenPaid[account][token] = rewardData[token].rewardPerNFTStored;
            }
        }
        _;
    }
    
    /* ========== EVENTS ========== */

    
}
