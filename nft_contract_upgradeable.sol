// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts-upgradeable@4.7.3/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/security/PausableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable@4.7.3/proxy/utils/UUPSUpgradeable.sol";

import "@openzeppelin/contracts/utils/Strings.sol";

contract Ramzinft is Initializable, ERC1155Upgradeable, OwnableUpgradeable, PausableUpgradeable, ERC1155BurnableUpgradeable, ERC1155SupplyUpgradeable, UUPSUpgradeable {
    /// @custom:oz-upgrades-unsafe-allow constructor
    string public name = "Ramzi NFT";

    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC1155_init("https://test-api.ramzinft.com/api/nfts/metadata/");
        __Ownable_init();
        __Pausable_init();
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function uri(uint256 id) public override view returns (string memory)
    {
        return string(abi.encodePacked(ERC1155Upgradeable.uri(id), Strings.toString(id), ".json"));
    }


    /**
        Check whether the requester is owner or he is approved or not
    **/

    modifier operationIsApproved(uint256[] memory ids){
        for (uint256 i = 0; i < ids.length; ++i) {
            require(exists(ids[i]) == false || _msgSender() == owner(), "operation should not permitted, Token doesn't exists");
        }
        _;
    }

    modifier isHolderOrOwner(address from,uint256[] memory ids, uint256[] memory amounts){
        for (uint256 i = 0; i < ids.length; ++i) {
            require((_msgSender() == from && balanceOf(_msgSender(),ids[i]) >= amounts[i]) || _msgSender() == owner(), "sender isn't holder!");
        }
        _;
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    /**
        Mint a new token in system
    **/
    function mint(
        address account,
        uint256 id,
        uint256 amount,
        bytes memory data
    ) public operationIsApproved(asSingletonArray(id)){
        _mint(account, id, amount, data);
    }

    function mintBatch(
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public operationIsApproved(ids){
        _mintBatch(to, ids, values, data);
    }

    /**
     * Burn existing token
     */
    function burn(
        address from,
        uint256 id,
        uint256 amount
    ) public override  isHolderOrOwner(from,asSingletonArray(id), asSingletonArray(amount)){
        ERC1155BurnableUpgradeable.burn(from,id,amount);
    }

    /**
     * Burn batch of tokens
     */
    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public override isHolderOrOwner(from, ids, amounts){
        ERC1155BurnableUpgradeable.burnBatch(from,ids,amounts);
    }

    /**
        Check happens before transfering tokens
    **/

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    internal
    whenNotPaused
    override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
    {
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }
    /**
        create an array from uint
    **/
    function asSingletonArray(uint256 element)
    private
    pure
    returns (uint256[] memory)
    {
        uint256[] memory array = new uint256[](1);
        array[0] = element;

        return array;
    }

    function _authorizeUpgrade(address newImplementation)
    internal
    onlyOwner
    override
    {}
}
