pragma solidity ^0.4.17;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/OysterPearl.sol";

contract TestOysterPearl {

  function testInitialBalanceUsingDeployedContract() public {

    OysterPearl oyster = OysterPearl(DeployedAddresses.OysterPearl());

    uint expected = 108000000000000000000000000;

    Assert.equal(oyster.balanceOf(tx.origin), expected, "Owner should have 108000000000000000000000000 PRLs initially");
  }

  function testInitialBalanceWithNewOysterPearl() public {

    OysterPearl oyster = new OysterPearl();

    uint expected = 10000;
    oyster.transfer(tx.origin, expected);

    Assert.equal(oyster.balanceOf(tx.origin), expected, "Owner should have 10000 PRLs initially");
  }

  function testBurnUsingNewOysterPearl() public {

    OysterPearl oyster = new OysterPearl();

    oyster.transfer(tx.origin, 20000);

    uint burnAmount = 10000;
    uint total = oyster.balanceOf(tx.origin);

    uint expected = total - burnAmount;
    oyster.burn(burnAmount);

    Assert.equal(burnAmount, expected, "Owner burned 10000 PRLs");

  }


}