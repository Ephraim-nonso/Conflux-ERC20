// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TestToken is ERC20 {

    // At the point of deployment, 10000e18 MyToken is minted to the deployer.
    constructor() ERC20("MyToken", "MTK") {
        _mint(msg.sender, 10000e18);
    }
}