// SPDX-License-Identifier: GPL-3.0-only
pragma solidity ^0.8.12;

import "../core/BasePaymaster.sol";

/**
 * test postOp revert with custom error
 */
error CustomError();

contract TestPaymasterRevertCustomError is BasePaymaster {
    bytes32 private constant INNER_OUT_OF_GAS = hex"deaddead";

    enum RevertType {
        customError,
        entryPointError
    }

    RevertType private revertType;

    // solhint-disable no-empty-blocks
    constructor(IEntryPoint _entryPoint) BasePaymaster(_entryPoint)
    {}

    function _validatePaymasterUserOp(UserOperation calldata userOp, bytes32, uint256)
    internal virtual override view
    returns (bytes memory context, uint256 validationData) {
        validationData = 0;
        context = abi.encodePacked(userOp.sender);
    }

    function setRevertType(RevertType _revertType) external {
        revertType = _revertType;
    }

    function _postOp(PostOpMode, bytes calldata, uint256) internal view override {
        if (revertType == RevertType.customError){
            revert CustomError();
        }
        else if (revertType == RevertType.entryPointError){
            // solium-disable-next-line security/no-inline-assembly
            assembly {
                mstore(0, INNER_OUT_OF_GAS)
                revert(0, 32)
            }
        }
    }
}
