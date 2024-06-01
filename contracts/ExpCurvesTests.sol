// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {exp} from "@prb/math/src/sd59x18/Math.sol";
import {wrap, unwrap} from "@prb/math/src/sd59x18/Casting.sol";

import "./EXPCurves.sol";

// ((EXP(curvature * (timeDelta / totalTimeInterval)) - 1 ) / (EXP(curvature) - 1)) * 100
// ((EXP(curvature * ( 1 - (timeDelta / totalTimeInterval))) - 1 ) / (EXP(curvature) - 1)) * 100
contract ExpCurvesTests is EXPCurves {
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
    // using 1e16 because the curvature is divided by 100 (2 decimals)
    return unwrap(exp(wrap(curvature * 1e16))) - 1e18;
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
        int(
          curvature *
            timeElapsedRatio(currentTimeframe, initialTimeframe, finalTimeframe)
        ) / 100;
    } else {
      return
        int(
          curvature *
            (1e18 -
              timeElapsedRatio(
                currentTimeframe,
                initialTimeframe,
                finalTimeframe
              ))
        ) / 100;
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
