// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Burnable.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";



contract ERC1155Basic is ERC1155, Ownable, Pausable, ERC1155Burnable, ERC1155Supply {
    string public name = "RamziNFT";

    constructor() ERC1155("https://api.ramzinft.com/api/nfts/metadata/") {}

    /**
        Destroy owner of contract
    **/
    function renounceOwnership() public view override onlyOwner {
        require(false , "Owner can not rennounce ownership!");
    }

    /**
        Transfer owner of contract
    **/
    function transferOwnership(address newOwner) public view override onlyOwner {
        require(false, "Owner can not transfer ownership!");
    }

    function setURI(string memory newuri) public onlyOwner {
        _setURI(newuri);
    }

    function uri(uint256 id) public override view returns (string memory)
    {
        return string(abi.encodePacked(ERC1155.uri(id), Strings.toString(id), ".json"));
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
        ERC1155Burnable.burn(from,id,amount);
    }

    /**
     * Burn batch of tokens
     */
    function burnBatch(
        address from,
        uint256[] memory ids,
        uint256[] memory amounts
    ) public override isHolderOrOwner(from, ids, amounts){
        ERC1155Burnable.burnBatch(from,ids,amounts);
    }

    /**
        Check happens before transfering tokens
    **/

    function _beforeTokenTransfer(address operator, address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        internal
        whenNotPaused
        override(ERC1155, ERC1155Supply)
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
}
