// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { IERC1271 } from "@openzeppelin/contracts/interfaces/IERC1271.sol";
import { ReentrancyGuard } from "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { IERC721 } from "@openzeppelin/contracts/token/ERC721/IERC721.sol";

import { ISignatureProtocol } from "./interface/ISignatureProtocol.sol";
import {
	ITransferRequestProtocol,
	IYieldSyncV1Vault,
	IYieldSyncV1VaultAccessControl,
	TransferRequest
} from "./interface/IYieldSyncV1Vault.sol";


contract YieldSyncV1Vault is
	IERC1271,
	ReentrancyGuard,
	IYieldSyncV1Vault
{
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


	address public override signatureProtocol;
	address public override transferRequestProtocol;

	IYieldSyncV1VaultAccessControl public immutable override YieldSyncV1VaultAccessControl;

	mapping (uint256 transferRequestId => TransferRequest transferRequest) internal _transferRequestId_transferRequest;


	constructor (
		address deployer,
		address _signatureProtocol,
		address _transferRequestProtocol,
		address _YieldSyncV1VaultAccessControl,
		address[] memory admins,
		address[] memory members
	)
	{
		signatureProtocol = _signatureProtocol;
		transferRequestProtocol = _transferRequestProtocol;

		YieldSyncV1VaultAccessControl = IYieldSyncV1VaultAccessControl(_YieldSyncV1VaultAccessControl);

		if (signatureProtocol != address(0))
		{
			ISignatureProtocol(signatureProtocol).yieldSyncV1VaultInitialize(deployer, address(this));
		}

		if (transferRequestProtocol != address(0))
		{
			ITransferRequestProtocol(transferRequestProtocol).yieldSyncV1VaultInitialize(deployer, address(this));
		}

		for (uint i = 0; i < admins.length; i++)
		{
			YieldSyncV1VaultAccessControl.adminAdd(address(this), admins[i]);
		}

		for (uint i = 0; i < members.length; i++)
		{
			YieldSyncV1VaultAccessControl.memberAdd(address(this), members[i]);
		}
	}


	modifier validYieldSyncV1Vault_transferRequestId_transferRequest(uint256 transferRequestId)
	{
		TransferRequest memory transferRequest = ITransferRequestProtocol(
			transferRequestProtocol
		).yieldSyncV1VaultAddress_transferRequestId_transferRequest(
			address(this),
			transferRequestId
		);

		require(transferRequest.amount > 0, "No TransferRequest found");

		_;
	}

	modifier accessAdmin()
	{
		(bool admin,) = YieldSyncV1VaultAccessControl.yieldSyncV1VaultAddress_participant_access(
			address(this),
			msg.sender
		);

		require(admin, "!admin");

		_;
	}

	modifier accessMember()
	{
		(, bool member) = YieldSyncV1VaultAccessControl.yieldSyncV1VaultAddress_participant_access(
			address(this),
			msg.sender
		);

		require(member, "!member");

		_;
	}


	/// @inheritdoc IERC1271
	function isValidSignature(bytes32 _messageHash, bytes memory _signature)
		public
		view
		override
		returns (bytes4 magicValue)
	{
		return IERC1271(signatureProtocol).isValidSignature(_messageHash, _signature);
	}


	/// @inheritdoc IYieldSyncV1Vault
	function adminAdd(address targetAddress)
		public
		override
		accessAdmin()
	{
		YieldSyncV1VaultAccessControl.adminAdd(address(this), targetAddress);
	}

	/// @inheritdoc IYieldSyncV1Vault
	function adminRemove(address admin)
		public
		override
		accessAdmin()
	{
		YieldSyncV1VaultAccessControl.adminRemove(address(this), admin);
	}

	/// @inheritdoc IYieldSyncV1Vault
	function memberAdd(address targetAddress)
		public
		override
		accessAdmin()
	{
		YieldSyncV1VaultAccessControl.memberAdd(address(this), targetAddress);
	}

	/// @inheritdoc IYieldSyncV1Vault
	function memberRemove(address member)
		public
		override
		accessAdmin()
	{
		YieldSyncV1VaultAccessControl.memberRemove(address(this), member);
	}

	/// @inheritdoc IYieldSyncV1Vault
	function signatureProtocolUpdate(address _signatureProtocol)
		public
		override
		accessAdmin()
	{
		ISignatureProtocol(_signatureProtocol).yieldSyncV1VaultInitialize(msg.sender, address(this));

		signatureProtocol = _signatureProtocol;

		emit UpdatedSignatureProtocol(signatureProtocol);
	}

	/// @inheritdoc IYieldSyncV1Vault
	function transferRequestProtocolUpdate(address _transferRequestProtocol)
		public
		override
		accessAdmin()
	{
		ITransferRequestProtocol(_transferRequestProtocol).yieldSyncV1VaultInitialize(msg.sender, address(this));

		transferRequestProtocol = _transferRequestProtocol;

		emit UpdatedSignatureProtocol(transferRequestProtocol);
	}


	/// @inheritdoc IYieldSyncV1Vault
	function yieldSyncV1VaultAddress_transferRequestId_transferRequestProcess(uint256 transferRequestId)
		public
		override
		nonReentrant()
		accessMember()
		validYieldSyncV1Vault_transferRequestId_transferRequest(transferRequestId)
	{
		(bool readyToBeProcessed, bool approved, string memory message) = ITransferRequestProtocol(
			transferRequestProtocol
		).yieldSyncV1VaultAddress_transferRequestId_transferRequestStatus(
			address(this),
			transferRequestId
		);

		require(readyToBeProcessed, message);

		if (approved)
		{
			TransferRequest memory transferRequest = ITransferRequestProtocol(
				transferRequestProtocol
			).yieldSyncV1VaultAddress_transferRequestId_transferRequest(
				address(this),
				transferRequestId
			);

			if (transferRequest.forERC20 && !transferRequest.forERC721)
			{
				if (IERC20(transferRequest.tokenAddress).balanceOf(address(this)) >= transferRequest.amount)
				{
					IERC20(transferRequest.tokenAddress).transfer(transferRequest.to, transferRequest.amount);
				}
				else
				{
					emit ProcessTransferRequestFailed(transferRequestId);
				}
			}

			if (!transferRequest.forERC20 && transferRequest.forERC721)
			{
				if (IERC721(transferRequest.tokenAddress).ownerOf(transferRequest.tokenId) == address(this))
				{
					IERC721(transferRequest.tokenAddress).transferFrom(
						address(this),
						transferRequest.to,
						transferRequest.tokenId
					);
				}
				else
				{
					emit ProcessTransferRequestFailed(transferRequestId);
				}
			}

			if (!transferRequest.forERC20 && !transferRequest.forERC721)
			{
				(bool success, ) = transferRequest.to.call{ value: transferRequest.amount }("");

				if (!success)
				{
					emit ProcessTransferRequestFailed(transferRequestId);
				}
			}

			emit TokensTransferred(msg.sender, transferRequest.to, transferRequest.amount);
		}

		ITransferRequestProtocol(
			transferRequestProtocol
		).yieldSyncV1VaultAddress_transferRequestId_transferRequestProcess(
			address(this),
			transferRequestId
		);
	}

	/// @inheritdoc IYieldSyncV1Vault
	function renounceMembership()
		public
		override
		accessMember()
	{
		YieldSyncV1VaultAccessControl.memberRemove(address(this), msg.sender);
	}
}
