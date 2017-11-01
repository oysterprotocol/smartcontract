pragma solidity ^0.4.18;

interface OysterPearl {
    function balanceOf(address _owner) public constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) public;
}

contract PearlDistribute {
    uint256 public price;
    uint256 public multi;
    uint256 public calcAmount;
    bool public calcMode;
    bool public complete;
    address public director;
    address public pearlContract = 0x1844b21593262668B7248d0f57a220CaaBA46ab9;
    OysterPearl pearl = OysterPearl(pearlContract);
    
    mapping (address => uint256) public pearlSend;
    
    function PearlDistribute() public {
        calcAmount = 0;
        price = 0;
        multi = 10 ** (uint256(18));
        calcMode = true;
        complete = false;
        director = msg.sender;
    }
    
    modifier onlyDirector {
        // Only the director is permitted
        require(msg.sender == director);
        _;
    }
    
    function ceil(uint256 a, uint256 m) internal pure returns (uint256) {
        return ((a + m - 1) / m) * m;
    }
    
    function transfer(address _send, uint256 _amount) public onlyDirector {
        pearl.transfer(_send, _amount);
    }
    
    function calculate(uint256 newPrice) public onlyDirector {
        require(!complete);
        require(newPrice>0);
        price = newPrice;
        calcMode = true;
        calcAmount = 0;
        stakes();
    }
    
    function distribute() public onlyDirector {
        require(!complete);
        require(calcMode);
        require(calcAmount>0);
        require(calcAmount <= pearl.balanceOf(this));
        calcMode = false;
        stakes();
        complete = true;
    }
    
    function add(address _target, uint256 _amount) internal {
        if (calcMode==true) {
            uint256 calcLocal = (_amount * multi * 5000) / price;
            calcLocal = ceil(calcLocal, multi);
            calcAmount += calcLocal;
            pearlSend[_target] = calcLocal;
        }
        else {
            pearl.transfer(_target, pearlSend[_target]);
        }
    }
    
    function stakes() internal {
        add(0x00F483bc6d54c19833d7CEA785d5053450ed5fD4, 920);
        add(0x002bC62E5910618383f984d278C9230FCe9745b1, 1500);
    }
}