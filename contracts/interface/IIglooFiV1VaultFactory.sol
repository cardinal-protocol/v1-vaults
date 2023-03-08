// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


/**
* @title IIglooFiV1VaultFactory
*/
interface IIglooFiV1VaultFactory {
	event DeployedIglooFiV1Vault(address indexed vaultAddress);
	event UpdatedDefaultSignatureManager(address defaultSignatureManager);
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
	* @notice CONSTANT Address of IglooFi Governance contract
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
	* @notice CONSTANT Address of IglooFi V1 Vault Record contract
	* @dev [!restriction]
	* @dev [view-address]
	* @return {address}
	*/
	function iglooFiV1VaultRecord()
		external
		view
		returns (address)
	;


	/**
	* @notice Fee
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
	* @notice Vault Id Tracker
	* @dev [!restriction]
	* @dev [view-uint256]
	* @return {uint256}
	*/
	function vaultIdTracker()
		external
		view
		returns (uint256)
	;

	/**
	* @notice IglooFiV1Vault Id to Address
	* @dev [!restriction]
	* @dev [view]
	* @param iglooFiV1VaultId {uint256}
	* @return {address}
	*/
	function iglooFiV1VaultIdToAddress(uint256 iglooFiV1VaultId)
		external
		view
		returns (address)
	;

	/**
	* @notice Creates a Vault
	* @dev [!restriction]
	* @dev [create]
	* @param admin {address}
	* @param members {address[]}
	* @param signatureManager {address}
	* @param againstVoteCountRequired {uint256}
	* @param forVoteCountRequired {uint256}
	* @param withdrawalDelaySeconds {uint256}
	* @return {address} Deployed vault
	*/
	function deployIglooFiV1Vault(
		address admin,
		address[] memory members,
		address signatureManager,
		bool useDefaultSignatureManager,
		uint256 againstVoteCountRequired,
		uint256 forVoteCountRequired,
		uint256 withdrawalDelaySeconds
	)
		external
		payable
		returns (address)
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
	* @notice Transfer Ether to 
	* @dev [restriction] IIglooFiGovernance AccessControlEnumerable → DEFAULT_ADMIN_ROLE
	* @dev [transfer]
	* @param to {uint256}
	*/
	function transferEther(address to)
		external
	;
}