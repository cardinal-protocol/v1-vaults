// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


struct MessageHashData {
	bytes signature;
	address signer;
	address[] signedMembers;
	uint256 signatureCount;
}


/**
* @title ISignatureManager
*/
interface ISignatureManager
{
	/**
	* @notice CONSTANT Address of YieldSync Governance contract
	* @dev [!restriction]
	* @dev [view-address]
	* @return {address}
	*/
	function yieldSyncGovernance()
		external
		view
		returns (address)
	;

	/**
	* @notice Getter for `_vaultMessageHashes`
	* @dev [!restriction]
	* @dev [view][mapping]
	* @param yieldSyncV1Vault {address}
	* @return {bytes32[]}
	*/
	function vaultMessageHashes(address yieldSyncV1Vault)
		external
		view
		returns (bytes32[] memory)
	;

	/**
	* @notice Getter for `_vaultMessageHashData`
	* @dev [!restriction][public]
	* @dev [view][mapping]
	* @param yieldSyncV1Vault {address}
	* @param messageHash {bytes32}
	* @return {MessageHashData}
	*/
	function vaultMessageHashData(address yieldSyncV1Vault, bytes32 messageHash)
		external
		view
		returns (MessageHashData memory)
	;


	/**
	* @notice Sign a Message Hash
	* @dev [!restriction][public]
	* @dev [create] `_vaultMessageHashData` value
	* @param yieldSyncV1Vault {address}
	* @param messageHash {bytes32}
	* @param signature {bytes}
	*/
	function signMessageHash(address yieldSyncV1Vault, bytes32 messageHash, bytes memory signature)
		external
	;


	/**
	* @notice Set pause
	* @dev [restriction] `IYieldSyncGovernance` AccessControlEnumerable → DEFAULT_ADMIN_ROLE
	* @dev [call-internal]
	* @param pause {bool}
	*/
	function updatePause(bool pause)
		external
	;
}
