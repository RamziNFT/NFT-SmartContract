// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/proxy/ERC1967/ERC1967Upgrade.sol";
import "@openzeppelin/contracts/proxy/Proxy.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract ProxyContract is ERC1967Upgrade, Proxy, Ownable {

    /**
     * @dev Initializes the upgradeable proxy with an initial implementation specified by `_logic`.
     *
     * If `_data` is nonempty, it's used as data in a delegate call to `_logic`. This will typically be an encoded
     * function call, and allows initializating the storage of the proxy like a Solidity constructor.
     */
    constructor(address _logic, bytes memory _data) payable {
        setAdmin(_msgSender());
        assert(_IMPLEMENTATION_SLOT == bytes32(uint256(keccak256('eip1967.proxy.implementation')) - 1));

        _upgradeToAndCall(_logic, _data, false);
    }

    /**
        OnlyADmin modifier
    */
    modifier onlyAdmin() {
        require(getAdmin() == msg.sender, "You are not admin");
        _;
    }

    /**
     * @dev Returns the current implementation address.
     */
    function getImplementation() public view returns (address)
    {
        return _implementation();
    }

    /**
     * Store new implementation for contract
     */
    function setImplementation(address newImplementation) public onlyAdmin {
        _upgradeTo(newImplementation);
    }

    /**
     * @dev Perform implementation upgrade with additional setup call.
     *
     * Emits an {Upgraded} event.
     */
    function setImplemenationAndCall(address newImplementation, bytes memory data, bool forceCall) public onlyAdmin
    {
        _upgradeToAndCall(newImplementation, data, forceCall);
    }

    /**
        Gets and returns system current admin
    **/
    function getAdmin() public view returns(address)
    {
        return _getAdmin();
    }

    /**
        Set new admin for proxy
    **/
    function setAdmin(address adminAddr) public onlyOwner
    {
        _changeAdmin(adminAddr);
    }

    /**
     * @dev Returns the current implementation address.
     */
    function _implementation() internal view virtual override returns (address impl) {
        return ERC1967Upgrade._getImplementation();
    }

}


