// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";

contract SignatureNFT is ERC721 {
    address immutable public signer;
    mapping(address => bool) public mintedAddress;

    constructor(string memory _name, string memory _symbol, address _signer) ERC721(_name, _symbol) {
        signer = _signer;
    }

    function mint(address _account, uint256 _tokenId, bytes memory _signature) external {
        bytes32 _msgHash = getMessageHash(_account, _tokenId);
        bytes32 _ethSignedMsgHash = ECDSA.toEthSignedMessageHash(_msgHash);
        require(verify(_ethSignedMsgHash, _signature), "invalid signature");
        require(!mintedAddress[_account], "account is minted");

        _mint(_account, _tokenId);
        mintedAddress[_account] = true;
    }

    function getMessageHash(address _account, uint256 _tokenId) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(_account, _tokenId));
    }

    function verify(bytes32 _msgHash, bytes memory _signature) public view returns (bool) {
        return SignatureChecker.isValidSignatureNow(signer, _msgHash, _signature);
    }
}