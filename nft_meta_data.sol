// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC1155/extensions/IERC1155MetadataURI.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
abstract contract NftMetaDataSupport is IERC1155MetadataURI, Ownable {

    //Meta information header uri container
    string internal _uri;

    /**
        Get URI For specific contract
    **/
    function uri(uint256 id) public override view returns (string memory)
    {
        return string(abi.encodePacked(_uri, "/", Strings.toString(id), ".json"));
    }

    /**
        Set new URI For tokens
    **/

    function setURI(string memory URI) public onlyOwner
    {
        _uri = URI;
    }
}