// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


/**
* @title IIglooFiV1VaultFactory
*/
interface IIglooFiV1VaultFactory {
	/* [event] */
	/**
	* @dev Emits when a vault is deployed
	*/
	event VaultDeployed(address indexed vaultAddress);

	/**
	* @dev Emits when a `fee` is updated
	*/
	event UpdatedFee(uint256 fee);


	receive ()
		external
		payable
	;


	fallback ()
		external
		payable
	;


	/**
	* @notice CONSTANT Address of Igloo Fi Governance contract
	* @dev [!restriction]
	* @dev [view-address]
	* @return {address}
	*/
	function iglooFiGovernance()
		external
		view
		returns (address)
	;

	/**
	* @notice Address for Signature Manager
	* @dev [!restriction]
	* @dev [view-address]
	* @return {address}
	*/
	function defaultSignatureManager()
		external
		view
		returns (address)
	;


	/**
	* @notice Get vault deployment fee
	* @dev [!restriction]
	* @dev [view-uint256]
	* @return {uint256}
	*/
	function fee()
		external
		view
		returns (uint256)
	;

	/**
	* @notice Get vault address
	* @dev [!restriction]
	* @dev [view]
	* @param vaultId {uint256}
	* @return {address}
	*/
	function vaultAddress(uint256 vaultId)
		external
		view
		returns (address)
	;

	/**
	* @notice Creates a Vault
	* @dev [!restriction]
	* @dev [create]
	* @param admin {address}
	* @param signatureManager {address}
	* @param requiredVoteCount {uint256}
	* @param withdrawalDelaySeconds {uint256}
	* @return {address} Deployed vault
	*/
	function deployVault(
		address admin,
		address signatureManager,
		bool useDefaultSignatureManager,
		uint256 requiredVoteCount,
		uint256 withdrawalDelaySeconds
	)
		external
		payable
		returns (address)
	;

	/**
	* @notice Set pause
	* @dev [restriction] IIglooFiGovernance AccessControlEnumerable → DEFAULT_ADMIN_ROLE
	* @dev [call-internal]
	* @param pause {bool}
	*/
	function setPause(bool pause)
		external
	;

	/**
	* @notice Update fee
	* @dev [restriction] IIglooFiGovernance AccessControlEnumerable → DEFAULT_ADMIN_ROLE
	* @dev [update] `fee`
	* @param _fee {uint256}
	*/
	function updateFee(uint256 _fee)
		external
	;

	/**
	* @notice Transfer Ether to the treasury
	* @dev [restriction] IIglooFiGovernance AccessControlEnumerable → DEFAULT_ADMIN_ROLE
	* @dev [transfer] to `treasury`
	* @param transferTo {uint256}
	*/
	function transferFunds(address transferTo)
		external
	;

	/**
	* @notice Updates default signature manager
	* @dev [restriction] IIglooFiGovernance AccessControlEnumerable → DEFAULT_ADMIN_ROLE
	* @dev [update] `defaultSignatureManager`
	* @param _defaultSignatureManager {address}
	*/
	function updateDefaultSignatureManager(address _defaultSignatureManager)
		external
	;
}