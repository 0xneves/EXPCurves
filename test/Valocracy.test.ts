import { expect } from "chai";
import { Contract } from "ethers";
import { ethers, network } from "hardhat";
import { ncurvature } from "./constants";

describe("Valocracy", async function () {
  let Valocracy: Contract;
  let owner: any;

  let day = 60 * 60 * 24;
  let month = 60 * 60 * 24 * 30;

  before(async function () {
    [owner] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("Valocracy", owner);
    Valocracy = await Factory.deploy();
    await Valocracy.deployed();
  });

  it("Should configure the contract", async function () {
    await Valocracy.setCurvature(ncurvature);
    await Valocracy.setVacationPeriod(month);
    expect(await Valocracy.curvature()).to.equal(ncurvature);
    expect(await Valocracy.vacationPeriod()).to.equal(month);
  });

  it("Should mint governance power", async function () {
    // Using voting power with 18 decimals
    await Valocracy.mint(owner.address, ethers.utils.parseEther("300"));
    const user = await Valocracy.votingPower(owner.address);
    const timestamp = (await ethers.provider.getBlock("latest")).timestamp;
    expect(user.votingPower).to.equal(ethers.utils.parseEther("300"));
    expect(user.lastUpdate).to.equal(timestamp);
  });

  it("Should hold less power accross time", async function () {
    const initialVotingPower = await Valocracy.balanceOf(owner.address);
    expect(initialVotingPower).to.equal(ethers.utils.parseEther("300"));
    console.log(
      "Current Voting Power: ",
      ethers.utils.formatEther(initialVotingPower).toString(),
    );

    for (let i = 0; i < 30; i++) {
      await network.provider.send("evm_increaseTime", [day]);
      await network.provider.send("evm_mine");
      const votingPower = await Valocracy.balanceOf(owner.address);
      console.log(
        "Current Voting Power: ",
        ethers.utils.formatEther(votingPower).toString(),
      );
    }
    const finalVotingPower = await Valocracy.balanceOf(owner.address);
    expect(finalVotingPower).to.equal(ethers.utils.parseEther("0"));
  });
});
