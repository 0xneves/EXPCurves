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
  let EXPCurves: Contract;
  let owner: any;

  before(async function () {
    [owner] = await ethers.getSigners();
    const Factory = await ethers.getContractFactory("ExpCurvesTests", owner);
    EXPCurves = await Factory.deploy();
    await EXPCurves.deployed();
  });

  it("Should return 100% when ascending and currentTimeframe is bigger than finalTimeframe", async function () {
    const curve = await EXPCurves.expcurve(1000, 100, 200, curvature, false);
    expect(curve).to.equal(0);
  });

  it("Should return 0% when descending and currentTimeframe is bigger than finalTimeframe", async function () {
    const curve = await EXPCurves.expcurve(1000, 100, 200, curvature, true);
    expect(curve).to.equal(ethers.utils.parseEther("100"));
  });

  it("Should revert when initialTimeframe is bigger than currentTimeframe", async function () {
    await expect(
      EXPCurves.expcurve(50, 100, 200, curvature, true),
    ).to.be.revertedWithCustomError(
      EXPCurves,
      "EXPCurveInvalidInitialTimeframe",
    );
  });

  it("Should revert when initialTimeframe is equal or bigger than currentTimeframe", async function () {
    await expect(
      EXPCurves.expcurve(120, 100, 100, curvature, true),
    ).to.be.revertedWithCustomError(
      EXPCurves,
      "EXPCurveInvalidInitialTimeframe",
    );
  });

  it("Should revert when curvature is invalid", async function () {
    await expect(
      EXPCurves.expcurve(150, 100, 200, 0, true),
    ).to.be.revertedWithCustomError(EXPCurves, "EXPCurveInvalidCurvature");

    await expect(
      EXPCurves.expcurve(150, 100, 200, 10001, true),
    ).to.be.revertedWithCustomError(EXPCurves, "EXPCurveInvalidCurvature");

    await expect(
      EXPCurves.expcurve(150, 100, 200, -10001, true),
    ).to.be.revertedWithCustomError(EXPCurves, "EXPCurveInvalidCurvature");
  });

  it("Should go from 100% to 0% using negative curvature", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const ep = await EXPCurves.expcurve(
        inputs[i],
        initialTimeframe,
        finalTimeframe,
        ncurvature,
        false,
      );
      console.log(ep == 0 ? 0 : Number(ep) / 1e18);
    }
  });

  it("Should go from 0 to 100% using negative curvature", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const ep = await EXPCurves.expcurve(
        inputs[i],
        initialTimeframe,
        finalTimeframe,
        ncurvature,
        true,
      );
      console.log(ep == 0 ? 0 : Number(ep) / 1e18);
    }
  });

  it("Should go from 100% to 0% using expcurve", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const ep = await EXPCurves.expcurve(
        inputs[i],
        initialTimeframe,
        finalTimeframe,
        curvature,
        false,
      );
      console.log(ep == 0 ? 0 : Number(ep) / 1e18);
    }
  });

  it("Should go from 0 to 100% using expcurve", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const ep = await EXPCurves.expcurve(
        inputs[i],
        initialTimeframe,
        finalTimeframe,
        curvature,
        true,
      );
      console.log(ep == 0 ? 0 : Number(ep) / 1e18);
    }
  });

  it("Should go from 100% to 0%", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const cn = await EXPCurves.curveNormalization(
        inputs[i],
        initialTimeframe,
        finalTimeframe,
        curvature,
        false,
      );
      console.log(cn == 0 ? 0 : Number(cn) / 1e18);
    }
  });

  it("Should go from 0 to 100%", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const cn = await EXPCurves.curveNormalization(
        inputs[i],
        initialTimeframe,
        finalTimeframe,
        curvature,
        true,
      );
      console.log(cn == 0 ? 0 : Number(cn) / 1e18);
    }
  });

  it("Should get Curve Normalization", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const cn = await EXPCurves.curveNormalization(
        inputs[i],
        initialTimeframe,
        finalTimeframe,
        curvature,
        true,
      );
      console.log(cn.toString());
    }
  });

  it("Should get Final Exp Scaling", async function () {
    const fes = await EXPCurves.finalExpScaling(curvature);
    console.log(fes.toString());
  });

  it("Should get Exponential (Euler)", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const exp = await EXPCurves.exponential(
        inputs[i],
        initialTimeframe,
        finalTimeframe,
        curvature,
        true,
      );
      console.log(exp.toString());
    }
  });

  it("Should get Curve Scalling Descending", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const cs = await EXPCurves.curveScaling(
        inputs[i],
        initialTimeframe,
        finalTimeframe,
        curvature,
        false,
      );
      console.log(cs.toString());
    }
  });

  it("Should get Curve Scalling Ascending", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const cs = await EXPCurves.curveScaling(
        inputs[i],
        initialTimeframe,
        finalTimeframe,
        curvature,
        true,
      );
      console.log(cs.toString());
    }
  });

  it("Should get Time Elapsed Ratio", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const ter = await EXPCurves.timeElapsedRatio(
        inputs[i],
        initialTimeframe,
        finalTimeframe,
      );
      console.log(ter.toString());
    }
  });

  it("Should get Total Time Intervals", async function () {
    const tti = await EXPCurves.totalTimeInterval(
      initialTimeframe,
      finalTimeframe,
    );
    console.log(tti.toString());
  });

  it("Should get Time Deltas", async function () {
    for (let i = 0; i < inputs.length; i++) {
      const td = await EXPCurves.timeDelta(inputs[i], initialTimeframe);
      console.log(td.toString());
    }
  });
});
