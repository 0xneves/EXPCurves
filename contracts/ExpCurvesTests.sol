// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {exp} from "@prb/math/src/sd59x18/Math.sol";
import {wrap, unwrap} from "@prb/math/src/sd59x18/Casting.sol";

// ((EXP(curvature * (timeDelta / totalTimeInterval)) - 1 ) / (EXP(curvature) - 1)) * 100
// ((EXP(curvature * ( 1 - (timeDelta / totalTimeInterval))) - 1 ) / (EXP(curvature) - 1)) * 100
contract ExpCurvesTests {
  function expcurve(
    uint32 currentTimeframe,
    uint32 initialTimeframe,
    uint32 finalTimeframe,
    int8 curvature,
    bool ascending
  ) public pure returns (int256) {
    if (initialTimeframe > currentTimeframe) revert("underflow");
    if (initialTimeframe > finalTimeframe) revert("underflow");
    if (curvature == 0) revert("invalid curvature");

    int256 td = int(uint256(currentTimeframe - initialTimeframe));
    int256 tti = int(uint256(finalTimeframe - initialTimeframe));

    int256 ter = unwrap(wrap(td) / wrap(tti));
    int256 cs;
    if (ascending) {
      cs = curvature * int(ter);
    } else {
      cs = curvature * (1e18 - int(ter));
    }

    int256 expo = unwrap(exp(wrap(cs))) - 1e18;
    int256 fes = unwrap(exp(wrap(int(curvature) * 1e18))) - 1e18;

    return unwrap(wrap(expo) / wrap(fes)) * 100;
  }

  function curveNormalization(
    uint256 currentTimeframe,
    uint256 initialTimeframe,
    uint256 finalTimeframe,
    int256 curvature,
    bool ascending
  ) public pure returns (int256) {
    return
      unwrap(
        wrap(
          exponential(
            currentTimeframe,
            initialTimeframe,
            finalTimeframe,
            curvature,
            ascending
          )
        ) / wrap(finalExpScaling(curvature))
      ) * 100; // percentage adjustment
  }

  function finalExpScaling(int256 curvature) public pure returns (int256) {
    return unwrap(exp(wrap(curvature * 1e18))) - 1e18;
  }

  function exponential(
    uint256 currentTimeframe,
    uint256 initialTimeframe,
    uint256 finalTimeframe,
    int256 curvature,
    bool ascending
  ) public pure returns (int256) {
    return
      unwrap(
        exp(
          wrap(
            curveScaling(
              currentTimeframe,
              initialTimeframe,
              finalTimeframe,
              curvature,
              ascending
            )
          )
        )
      ) - 1e18;
  }

  function curveScaling(
    uint256 currentTimeframe,
    uint256 initialTimeframe,
    uint256 finalTimeframe,
    int256 curvature,
    bool ascending
  ) public pure returns (int256) {
    if (ascending) {
      return
        curvature *
        timeElapsedRatio(currentTimeframe, initialTimeframe, finalTimeframe);
    } else {
      return
        curvature *
        (1e18 -
          timeElapsedRatio(currentTimeframe, initialTimeframe, finalTimeframe));
    }
  }

  function timeElapsedRatio(
    uint256 currentTimeframe,
    uint256 initialTimeframe,
    uint256 finalTimeframe
  ) public pure returns (int256) {
    return
      unwrap(
        wrap(timeDelta(currentTimeframe, initialTimeframe)) /
          wrap(totalTimeInterval(initialTimeframe, finalTimeframe))
      );
  }

  function totalTimeInterval(
    uint256 initialTimeframe,
    uint256 finalTimeframe
  ) public pure returns (int256) {
    unchecked {
      if (initialTimeframe > finalTimeframe) revert("underflow");
      return int(finalTimeframe - initialTimeframe);
    }
  }

  function timeDelta(
    uint256 currentTimeframe,
    uint256 initialTimeframe
  ) public pure returns (int256) {
    unchecked {
      if (initialTimeframe > currentTimeframe) revert("underflow");
      return int(currentTimeframe - initialTimeframe);
    }
  }
}
