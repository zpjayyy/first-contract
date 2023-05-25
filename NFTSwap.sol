// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract NFTSwap is IERC721Receiver {

    event List(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 price);

    event Purchase(address indexed buyer, address indexed nftAddress, uint256 indexed tokenId, uint256 price);

    event Revoke(address indexed seller, address indexed nftAddress, uint256 indexed tokenId);

    event Update(address indexed seller, address indexed nftAddress, uint256 indexed tokenId, uint256 newPrice);

    struct Order {
        address owner;
        uint256 price;
    }

    mapping (address => mapping (uint256 => Order)) public nftList;

    fallback() external payable {}

    receive() external payable {}

    function list(address _nftAddress, uint256 _tokenId, uint256 _price) public {
        IERC721 _nft = IERC721(_nftAddress);
        require(_nft.getApproved(_tokenId) == address(this), "Need approval");
        require(_price > 0);

        Order storage _order = nftList[_nftAddress][_tokenId];
        _order.owner = msg.sender;
        _order.price = _price;

        _nft.safeTransferFrom(msg.sender, address(this), _tokenId);

        emit List(msg.sender, _nftAddress, _tokenId, _price);
    }

    function purchase(address _nftAddress, uint256 _tokenId) public payable {
        Order storage _order = nftList[_nftAddress][_tokenId];
        require(_order.price > 0, "invalid price");
        require(msg.value >= _order.price, "increase price");

        IERC721 _nft = IERC721(_nftAddress);
        require(_nft.ownerOf(_tokenId) == address(this), "invalid order");

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        payable(_order.owner).transfer(_order.price);
        payable(msg.sender).transfer(msg.value - _order.price);

        delete nftList[_nftAddress][_tokenId];

        emit Purchase(msg.sender, _nftAddress, _tokenId, _order.price);
    }

    function revoke(address _nftAddress, uint256 _tokenId) public {
        Order storage _order = nftList[_nftAddress][_tokenId];
        require(msg.sender == _order.owner, "not owner");

        IERC721 _nft = IERC721(_nftAddress);
        require(_nft.ownerOf(_tokenId) == address(this), "invalid order");

        _nft.safeTransferFrom(address(this), msg.sender, _tokenId);
        delete nftList[_nftAddress][_tokenId];

        emit Revoke(msg.sender, _nftAddress, _tokenId);        
    }

    function update(address _nftAddress, uint256 _tokenId, uint256 _newPrice) public {
        require(_newPrice > 0, "Invalid Price"); // NFT价格大于0
        Order storage _order = nftList[_nftAddress][_tokenId]; // 取得Order
        require(_order.owner == msg.sender, "Not Owner"); // 必须由持有人发起
        // 声明IERC721接口合约变量
        IERC721 _nft = IERC721(_nftAddress);
        require(_nft.ownerOf(_tokenId) == address(this), "Invalid Order"); // NFT在合约中

        // 调整NFT价格
        _order.price = _newPrice;

        // 释放Update事件
        emit Update(msg.sender, _nftAddress, _tokenId, _newPrice);
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return IERC721Receiver.onERC721Received.selector;
    }
}
