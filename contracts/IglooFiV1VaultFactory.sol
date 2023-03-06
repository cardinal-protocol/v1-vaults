// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { IIglooFiGovernance } from "@igloo-fi/v1-sdk/contracts/interface/IIglooFiGovernance.sol";
import { Pausable } from "@openzeppelin/contracts/security/Pausable.sol";

import { IglooFiV1Vault } from "./IglooFiV1Vault.sol";
import { IIglooFiV1VaultFactory } from "./interface/IIglooFiV1VaultFactory.sol";


/**
* @title IglooFiV1VaultFactory
*/
contract IglooFiV1VaultFactory is
	Pausable,
	IIglooFiV1VaultFactory
{
	// [address]
	address public override iglooFiGovernance;
	address public override defaultSignatureManager;

	// [uint256]
	uint256 public override fee;
	uint256 internal _vaultIdTracker;

	// [mapping]
	mapping (uint256 iglooFiV1VaultId => address iglooFiV1VaultAddress) internal _iglooFiV1VaultIdToAddress;


	constructor (address _iglooFiGovernance)
	{
		_pause();

		iglooFiGovernance = _iglooFiGovernance;

		fee = 0;

		_vaultIdTracker = 0;
	}


	receive ()
		external
		payable
		override
	{}


	fallback ()
		external
		payable
		override
	{}


	modifier onlyIglooFiGovernanceAdmin() {
		require(
			IIglooFiGovernance(iglooFiGovernance).hasRole(
				IIglooFiGovernance(iglooFiGovernance).governanceRoles("DEFAULT_ADMIN_ROLE"),
				_msgSender()
			),
			"!auth"
		);

		_;
	}


	/// @inheritdoc IIglooFiV1VaultFactory
	function iglooFiV1VaultIdToAddress(uint256 iglooFiV1VaultId)
		public
		view
		override
		returns (address)
	{
		return _iglooFiV1VaultIdToAddress[iglooFiV1VaultId];
	}


	/// @inheritdoc IIglooFiV1VaultFactory
	function deployIglooFiV1Vault(
		address admin,
		address signatureManager,
		bool useDefaultSignatureManager,
		uint256 againstVoteCountRequired,
		uint256 forVoteCountRequired,
		uint256 withdrawalDelaySeconds
	)
		public
		payable
		override
		whenNotPaused()
		returns (address)
	{
		require(msg.value >= fee, "!msg.value");

		IglooFiV1Vault deployedContract = new IglooFiV1Vault(
			admin,
			useDefaultSignatureManager ? defaultSignatureManager : signatureManager,
			againstVoteCountRequired,
			forVoteCountRequired,
			withdrawalDelaySeconds
		);

		_iglooFiV1VaultIdToAddress[_vaultIdTracker] = address(deployedContract);

		_vaultIdTracker++;

		emit DeployedIglooFiV1Vault(address(deployedContract));

		return address(deployedContract);
	}


	/// @inheritdoc IIglooFiV1VaultFactory
	function updatePause(bool pause)
		public
		override
		onlyIglooFiGovernanceAdmin()
	{
		if (pause)
		{
			_pause();
		}
		else
		{
			_unpause();
		}
	}


	/// @inheritdoc IIglooFiV1VaultFactory
	function updateDefaultSignatureManager(address _defaultSignatureManager)
		public
		override
		whenNotPaused()
		onlyIglooFiGovernanceAdmin()
	{
		defaultSignatureManager = _defaultSignatureManager;

		emit UpdatedDefaultSignatureManager(defaultSignatureManager);
	}

	/// @inheritdoc IIglooFiV1VaultFactory
	function updateFee(uint256 _fee)
		public
		override
		onlyIglooFiGovernanceAdmin()
	{
		fee = _fee;

		emit UpdatedFee(fee);
	}

	/// @inheritdoc IIglooFiV1VaultFactory
	function transferEther(address to)
		public
		override
		whenNotPaused()
		onlyIglooFiGovernanceAdmin()
	{
		// [transfer]
		(bool success, ) = to.call{value: address(this).balance}("");

		require(success, "Failed");
	}
}