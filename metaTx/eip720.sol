// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract EIP2771Base {

    /**
        Define meta transaction domain seperator in order to restrict meta tx from other platforms
    **/
    struct EIP712Domain {
        string name;
        string version;
        address verifyingContract;
        bytes32 chainId;
    }

    //ERC Version container for meta tx'es
    string public constant ERC712_VERSION = "1";

    //Function Hash of meta transaction
    bytes32 internal constant EIP712_DOMAIN_TYPEHASH =
    keccak256(
        bytes(
            "EIP712Domain(string name,string version,address verifyingContract, bytes32 chainId)"
        )
    );

    //Contains domain seperator hash
    bytes32 internal domainSeperator;

    /**
        Creates a hash for domain seperator struct
    **/
    function _setDomainSeperator(string memory name) internal {
        domainSeperator = keccak256(
            abi.encode(
                EIP712_DOMAIN_TYPEHASH,
                keccak256(bytes(name)),
                keccak256(bytes(ERC712_VERSION)),
                address(this),
                bytes32(getChainId())
            )
        );
    }

    /**
        Get and return domain seperator hash
    **/
    function getDomainSeperator() public view returns (bytes32) {
        return domainSeperator;
    }

    /**
        Get and return network chain ID
    **/
    function getChainId() public view returns (uint256) {
        uint256 id;
        assembly {
            id := chainid()
        }
        return id;
    }

    /**
        Create type hash message for validation and recovering signer address for meta tx's executaion
    **/
    function toTypedMessageHash(bytes32 messageHash)
    internal
    view
    returns (bytes32)
    {
        return
        keccak256(
            abi.encodePacked("\x19\x01", getDomainSeperator(), messageHash)
        );
    }
}


contract NativeMetaTransaction is EIP712Base {

    //Type hash for meta transaction's struct
    bytes32 private constant META_TRANSACTION_TYPEHASH =
    keccak256(
        bytes(
            "MetaTransaction(uint256 nonce,address from,bytes functionSignature)"
        )
    );

    //Event for alerting that meta tx executed
    event MetaTransactionExecuted(
        address userAddress,
        address payable relayerAddress,
        bytes functionSignature
    );

    //Keeping Address nonces in order to prevent double executaion for metatx
    mapping(address => uint256) nonces;

    /*
     * Meta transaction structure for metatx execution
     */
    struct MetaTransaction {
        uint256 nonce;
        address from;
        bytes functionSignature;
    }

    function executeMetaTransaction(
        address userAddress,
        bytes memory functionSignature,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) external payable returns (bytes memory) {
        MetaTransaction memory metaTx =
        MetaTransaction({
        nonce: nonces[userAddress],
        from: userAddress,
        functionSignature: functionSignature
        });

        require(
            verify(userAddress, metaTx, sigR, sigS, sigV),
            "Signer and signature do not match"
        );

        // increase nonce for user (to avoid re-use)
        nonces[userAddress] += 1;

        emit MetaTransactionExecuted(
            userAddress,
            payable(msg.sender),
            functionSignature
        );

        // Append userAddress and relayer address at the end to extract it from calling context
        (bool success, bytes memory returnData) =
        address(this).call(
            abi.encodePacked(functionSignature, userAddress)
        );
        require(success, "Function call not successful");

        return returnData;
    }

    /**
        Makes hash for meta transaction for metatx verification
    **/
    function hashMetaTransaction(MetaTransaction memory metaTx)
    internal
    pure
    returns (bytes32)
    {
        return
        keccak256(
            abi.encode(
                META_TRANSACTION_TYPEHASH,
                metaTx.nonce,
                metaTx.from,
                keccak256(metaTx.functionSignature)
            )
        );
    }

    /**
        Get and return address's current nonce
    **/
    function getNonce(address user) public view returns (uint256 nonce) {
        nonce = nonces[user];
    }

    /**
        Verify meta transaction in order to execution
    **/
    function verify(
        address signer,
        MetaTransaction memory metaTx,
        bytes32 sigR,
        bytes32 sigS,
        uint8 sigV
    ) internal view returns (bool) {
        require(signer != address(0), "NativeMetaTransaction: INVALID_SIGNER");
        return
        signer == ECDSA.recover(
            toTypedMessageHash(hashMetaTransaction(metaTx)),
            sigV,
            sigR,
            sigS
        );
    }
}