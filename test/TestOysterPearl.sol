pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/OysterPearl.sol";

contract TestOysterPearl {

  // test 'balanceOf' deployed
  function testInitialBalanceUsingDeployedContract() public {

    OysterPearl oyster = OysterPearl(DeployedAddresses.OysterPearl());

    uint expected = 108000000000000000000000000;

    Assert.equal(oyster.balanceOf(tx.origin), expected, "Owner should have 108000000000000000000000000 PRLs initially");
  }

  // test 'balanceOf'
  function testInitialBalanceWithNewOysterPearl() public {

    OysterPearl oyster = new OysterPearl();

    uint expected = 10000;
    oyster.transfer(tx.origin, expected);

    Assert.equal(oyster.balanceOf(tx.origin), expected, "Owner should have 10000 PRLs initially");
  }

  // test 'burn'
  function testBurnUsingNewOysterPearl() public {

    OysterPearl oyster = new OysterPearl();

    oyster.transfer(tx.origin, 20000);

    uint burnAmount = 10000;
    uint total = oyster.balanceOf(tx.origin);

    uint expected = total - burnAmount;
    oyster.burn(burnAmount);

    Assert.equal(burnAmount, expected, "Owner burned 10000 PRLs");

  }

  // test 'burnFrom'
  function testBurnFromUsingNewOysterPearl() public {

    OysterPearl oyster = new OysterPearl();

    uint256 totalBurn = 1000;
    address from = 0xbA336bf608e9d7287EF62a560A3F5522bFB9b928;
    uint256 startBalance = from.balance();

    from.transfer(2000);

    bool burned = oyster.burnFrom(from, totalBurn);
    uint256 endBalance = from.balance();
    Assert.equal(startBalance, endBalance, "Owner burned 1000 PRLs from user");

  }

  // test 'bury'
  function testBuryUsingDeployedContract() public {

      OysterPearl oyster = OysterPearl(DeployedAddresses.OysterPearl());

      // bury() returns (bool success)
      // TODO oyster contract address is buried? or do we need to pass an address to bury in the contract
      bool buried = oyster.bury();

      Assert.equal(true, buried, "Owner successfully called bury");
  }

  // test 'claim'
  function testClaimUsingDeployedContract() public {

    OysterPearl oyster = OysterPearl(DeployedAddresses.OysterPearl());

    // claim(address _payout, address _fee) returns (bool success)
    address websiteOwner = 0x5aeda56215b167893e80b4fe645ba6d5bab767de;
    // pay broker node address that unlocked the PRL
    address brokerNode = 0x6330a553fc93768f612722bb8c2ec78ac90b3bbc;

    bool claimed = oyster.claim(websiteOwner, brokerNode);

    Assert.equal(true, claimed, "Owner successfully claimed PRL and payed the broker node");
  }

  // test 'transfer'
  function testSendPRLUsingDeployedContract() public {

    OysterPearl oyster = OysterPearl(DeployedAddresses.OysterPearl());

    // transfer(address _to, uint256 _value) returns (bool success)
    address to = 0x2191ef87e392377ec08e7c08eb105ef5448eced5;
    // total PRLs to transfer
    uint256 totalPRLs = 1000;

    bool transferred = oyster.transfer(to, totalPRLs);

    Assert.equals(true, transferred, "Owner successfully transferred PRL");
  }

}