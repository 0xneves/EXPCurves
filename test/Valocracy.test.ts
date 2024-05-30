import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import {
  initialTimeframe,
  finalTimeframe,
  curvature,
  ncurvature,
  inputs,
} from "./constants";

describe("Exponential Curve", async function () {
  let Valocracy: Contract;
  let owner: any;

  before(async function () {
    [owner] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("Valocracy", owner);
    Valocracy = await Factory.deploy();
    await Valocracy.deployed();
  });
});
