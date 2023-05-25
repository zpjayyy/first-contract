pragma solidity ^0.8.4;

contract demo {

    address owner;

    mapping(address => uint256) public _balance;

    event Transfer(address indexed from, address indexed to, uint256 amount);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    function _transfer(address from, address to, uint256 amount) external {
        _balance[from] = 100000;
        _balance[from] -= amount;

        _balance[to] += amount;

        emit Transfer(from, to, amount);
    }
}
