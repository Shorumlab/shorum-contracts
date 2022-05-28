// SPDX-License-Identifier: MIT

pragma solidity 0.8.10;

import {IFollowModule} from '../../../interfaces/IFollowModule.sol';
import {ILensHub} from '../../../interfaces/ILensHub.sol';
import {Errors} from '../../../libraries/Errors.sol';
import {FeeModuleBase} from '../FeeModuleBase.sol';
import {ModuleBase} from '../ModuleBase.sol';
import {FollowValidatorFollowModuleBase} from './FollowValidatorFollowModuleBase.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {SafeERC20} from '@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol';
import {IERC721} from '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '../../FollowerRewardsDistributor.sol';
/**
 * @notice A struct containing the necessary data to execute follow actions on a given profile.
 *
 * @param currency The currency associated with this profile.
 * @param amount The following cost associated with this profile.
 * @param recipient The recipient address associated with this profile.
 */
struct ProfileData {
    address currency;
    uint256 amount;
    address recipient;
    address distributor;
}

pragma solidity >=0.5.0;

interface IFollowerRewardsDistributor {
    function initialize(uint256) external;

    function register(address, uint256) external;
}

// Back a profile means using a small fund to support the Folowee and trust its taste.
// Every time the profile profit from the nft treading, the folowee will get interest distributed
//
//
/**
 * @title BackerFeeFollowModule
 * @author Starit
 *
 * @notice This is a simple Lens FollowModule implementation, inheriting from the IFollowModule interface, but with additional
 * variables that can be controlled by governance, such as the governance & treasury addresses as well as the treasury fee.
 */
contract BackerFeeFollowModule is FeeModuleBase, FollowValidatorFollowModuleBase {
    using SafeERC20 for IERC20;

    mapping(uint256 => ProfileData) internal _dataByProfile;
    address[] public allDistributors;
    mapping(address => bool) invitedAddress; // invited address don't need to pay fees

    constructor(address hub, address moduleGlobals) FeeModuleBase(moduleGlobals) ModuleBase(hub) {}

    /**
     * @notice This follow module levies a fee on follows
     *
     * @param profileId The profile ID of the profile to initialize this module for.
     * @param data The arbitrary data parameter, decoded into:
     *      address currency: The currency address, must be internally whitelisted.
     *      uint256 amount: The currency total amount to levy.
     *      address recipient: The custom recipient address to direct earnings to.
     *
     * @return bytes An abi encoded bytes parameter, which is the same as the passed data parameter.
     */
    function initializeFollowModule(uint256 profileId, bytes calldata data)
        external
        override
        onlyHub
        returns (bytes memory)
    {
        (uint256 amount, address currency, address recipient) = abi.decode(
            data,
            (uint256, address, address)
        );
        if (!_currencyWhitelisted(currency) || recipient == address(0))
            revert Errors.InitParamsInvalid();

        _dataByProfile[profileId].amount = amount;
        _dataByProfile[profileId].currency = currency;
        _dataByProfile[profileId].recipient = recipient;
        _dataByProfile[profileId].distributor = address(0);
        createDistributor(profileId);
        return data;
    }

    function createDistributor(uint256 profileId) public returns (address distributor) {
        // Todo:: verify identity

        require(
            _dataByProfile[profileId].distributor == address(0),
            'distributor-has-been-created'
        );
        // create distributor contract and bind it to the user
        // _dataByProfile[profileId].distributor = address(0x01);
        bytes memory bytecode = type(FollowerRewardsDistributor).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(profileId));
        assembly {
            distributor := create2(0, add(bytecode, 32), mload(bytecode), salt)
        }
        // init distributor
        IFollowerRewardsDistributor(distributor).initialize(profileId);
        _dataByProfile[profileId].distributor = distributor;
        allDistributors.push(distributor);
        emit DistributorCreated(profileId, distributor, allDistributors.length);
    }

    /**
     * @dev Inviate an address and directly follow
     * This is to allow user to promote their account
     * Limitation should be added in the future
     */
    function invite(address[] calldata _inviteAddresses, uint256 profileId) external {
        // Todo:: verify profile id auth
        for (uint256 i = 0; i < _inviteAddresses.length; i++) {
            invitedAddress[_inviteAddresses[i]] = true;
        }
    }

    /**
     * @dev Processes a follow by:
     *  1. Charging a fee
     */
    function processFollow(
        address follower,
        uint256 profileId,
        bytes calldata data
    ) external override onlyHub {
        uint256 amount = _dataByProfile[profileId].amount;
        address currency = _dataByProfile[profileId].currency;
        _validateDataIsExpected(data, currency, amount);

        if (invitedAddress[follower] != true) {
            (address treasury, uint16 treasuryFee) = _treasuryData();
            address recipient = _dataByProfile[profileId].recipient;
            uint256 treasuryAmount = (amount * treasuryFee) / BPS_MAX;
            uint256 adjustedAmount = amount - treasuryAmount;

            IERC20(currency).safeTransferFrom(follower, recipient, adjustedAmount);
            if (treasuryAmount > 0) {
                IERC20(currency).safeTransferFrom(follower, treasury, treasuryAmount);
            }
        }

        // Register in distributor
        address distributor = _dataByProfile[profileId].distributor;
        require(distributor != address(0), 'distributor-not-created');
        IFollowerRewardsDistributor(distributor).register(follower, profileId); // Todo:: check token id
    }

    /**
     * @dev We don't need to execute any additional logic on transfers in this follow module.
     */
    function followModuleTransferHook(
        uint256 profileId,
        address from,
        address to,
        uint256 followNFTTokenId
    ) external override {}

    /**
     * @notice Returns the profile data for a given profile, or an empty struct if that profile was not initialized
     * with this module.
     *
     * @param profileId The token ID of the profile to query.
     *
     * @return ProfileData The ProfileData struct mapped to that profile.
     */
    function getProfileData(uint256 profileId) external view returns (ProfileData memory) {
        return _dataByProfile[profileId];
    }

    event DistributorCreated(uint256, address, uint256);
}
