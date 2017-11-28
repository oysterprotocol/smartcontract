pragma solidity ^0.4.18;

interface OysterPearl {
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public;
}

contract PearlDistribute {
    uint256 public month;
    uint256 public allowance;
    uint256 public last;
    address public director;
    address public pearlContract = 0x1844b21593262668B7248d0f57a220CaaBA46ab9;
    OysterPearl pearl = OysterPearl(pearlContract);

    function PearlDistribute() public {
        last = 0;
        director = msg.sender;
        month = 60 * 60 * 24 * 30;
        allowance = 1000000;
    }

    modifier onlyDirector {
        // Only the director is permitted
        require(msg.sender == director);
        _;
    }

    function rescue(address _send, uint256 _amount) public onlyDirector {
        require(block.timestamp > 1527868800);//rescue function activates after June 1st 2018
        pearl.transfer(_send, _amount);
    }

    function withdraw() public onlyDirector {
        require((block.timestamp - last) > month);
        last = block.timestamp;
        pearl.transfer(director, allowance);
    }
}