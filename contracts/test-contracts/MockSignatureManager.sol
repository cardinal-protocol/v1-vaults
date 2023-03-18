// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;


import { SignatureManager } from "../SignatureManager.sol";


contract MockSignatureManager is SignatureManager {
	constructor (address _yieldSyncGovernance, address _YieldSyncV1VaultRecord)
		SignatureManager(_yieldSyncGovernance, _YieldSyncV1VaultRecord)
	{}
}
