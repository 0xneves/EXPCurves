import { expect } from "chai";
import { Contract } from "ethers";
import { ethers } from "hardhat";
import {
  initialTimeframe,
  finalTimeframe,
  curvature,
  inputs,
} from "./constants";

describe("EXPCurves", async function () {
  let expCurves: Contract;
  let owner: any;

  before(async function () {
    [owner] = await ethers.getSigners();
    const EXPCurves = await ethers.getContractFactory("EXPCurves", owner);
    expCurves = await EXPCurves.deploy();
    await expCurves.deployed();
  });

  it("Should get Curve Normalization", async function () {
    const cn0 = await expCurves.curveNormalization(
      inputs.input1,
      finalTimeframe,
      initialTimeframe,
      curvature,
    );
    console.log(cn0.toString());
    const cn1 = await expCurves.curveNormalization(
      inputs.input2,
      finalTimeframe,
      initialTimeframe,
      curvature,
    );
    console.log(cn1.toString());
    const cn2 = await expCurves.curveNormalization(
      inputs.input3,
      finalTimeframe,
      initialTimeframe,
      curvature,
    );
    console.log(cn2.toString());
  });

  it("Should get Final Exp Scaling", async function () {
    const fes0 = await expCurves.finalExpScaling(curvature);
    console.log(fes0.toString());
  });

  it("Should get Exponential (Euler)", async function () {
    const exp0 = await expCurves.exponential(
      inputs.input1,
      finalTimeframe,
      initialTimeframe,
      curvature,
    );
    console.log(exp0.toString());
    const exp1 = await expCurves.exponential(
      inputs.input2,
      finalTimeframe,
      initialTimeframe,
      curvature,
    );
    console.log(exp1.toString());
    const exp2 = await expCurves.exponential(
      inputs.input3,
      finalTimeframe,
      initialTimeframe,
      curvature,
    );
    console.log(exp2.toString());
  });

  it("Should get Curve Scalling", async function () {
    const cs0 = await expCurves.curveScaling(
      inputs.input1,
      finalTimeframe,
      initialTimeframe,
      curvature,
    );
    console.log(cs0.toString());
    const cs1 = await expCurves.curveScaling(
      inputs.input2,
      finalTimeframe,
      initialTimeframe,
      curvature,
    );
    console.log(cs1.toString());
    const cs2 = await expCurves.curveScaling(
      inputs.input3,
      finalTimeframe,
      initialTimeframe,
      curvature,
    );
    console.log(cs2.toString());
  });

  it("Should get Time Elapsed Ratio", async function () {
    const ter0 = await expCurves.timeElapsedRatio(
      inputs.input1,
      finalTimeframe,
      initialTimeframe,
    );
    console.log(ter0.toString());
    const ter1 = await expCurves.timeElapsedRatio(
      inputs.input2,
      finalTimeframe,
      initialTimeframe,
    );
    console.log(ter1.toString());
    const ter2 = await expCurves.timeElapsedRatio(
      inputs.input3,
      finalTimeframe,
      initialTimeframe,
    );
    console.log(ter2.toString());
  });

  it("Should get Total Time Intervals", async function () {
    const tti0 = await expCurves.totalTimeInterval(
      finalTimeframe,
      initialTimeframe,
    );
    console.log(tti0.toString());
  });

  it("Should get Time Deltas", async function () {
    const td0 = await expCurves.timeDelta(inputs.input1, initialTimeframe);
    console.log(td0.toString());
    const td1 = await expCurves.timeDelta(inputs.input2, initialTimeframe);
    console.log(td1.toString());
    const td2 = await expCurves.timeDelta(inputs.input3, initialTimeframe);
    console.log(td2.toString());
  });
});
