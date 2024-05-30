// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {exp, div} from "@prb/math/src/ud60x18/Math.sol";
import {wrap, unwrap} from "@prb/math/src/ud60x18/Casting.sol";

// ((EXP(curvature * (timeDelta / totalTimeInterval)) - 1 ) / (EXP(curvature) - 1)) * 100
// ((EXP(curvature * ( 1 - (timeDelta / totalTimeInterval))) - 1 ) / (EXP(curvature) - 1)) * 100
contract ExponentialCurve {
  function exponentialPercentage(
    uint256 currentTimeframe,
    uint256 initialTimeframe,
    uint256 finalTimeframe,
    uint256 curvature,
    bool ascending
  ) public pure returns (uint256) {
    if (initialTimeframe > currentTimeframe) revert("underflow");
    if (initialTimeframe > finalTimeframe) revert("underflow");

    uint256 td = currentTimeframe - initialTimeframe;
    uint256 tti = finalTimeframe - initialTimeframe;

    uint256 ter = unwrap(wrap(td) / wrap(tti));
    uint256 cs;
    if (ascending) {
      cs = curvature * ter;
    } else {
      cs = curvature * (1e18 - ter);
    }

    uint256 expo = unwrap(exp(wrap(cs))) - 1e18;
    uint256 fes = unwrap(exp(wrap(curvature * 1e18))) - 1e18;

    return unwrap(wrap(expo) / wrap(fes)) * 100;
  }

  function curveNormalization(
    uint256 currentTimeframe,
    uint256 initialTimeframe,
    uint256 finalTimeframe,
    uint256 curvature,
    bool ascending
  ) public pure returns (uint256) {
    return
      unwrap(
        div(
          wrap(
            exponential(
              currentTimeframe,
              initialTimeframe,
              finalTimeframe,
              curvature,
              ascending
            )
          ),
          wrap(finalExpScaling(curvature))
        )
      ) * 100; // percentage adjustment
  }

  function finalExpScaling(uint256 curvature) public pure returns (uint256) {
    return unwrap(exp(wrap(curvature * 1e18))) - 1e18;
  }

  function exponential(
    uint256 currentTimeframe,
    uint256 initialTimeframe,
    uint256 finalTimeframe,
    uint256 curvature,
    bool ascending
  ) public pure returns (uint256) {
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
    uint256 curvature,
    bool ascending
  ) public pure returns (uint256) {
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
  ) public pure returns (uint256) {
    return
      unwrap(
        div(
          wrap(timeDelta(currentTimeframe, initialTimeframe)),
          wrap(totalTimeInterval(initialTimeframe, finalTimeframe))
        )
      );
  }

  function totalTimeInterval(
    uint256 initialTimeframe,
    uint256 finalTimeframe
  ) public pure returns (uint256) {
    unchecked {
      if (initialTimeframe > finalTimeframe) revert("underflow");
      return finalTimeframe - initialTimeframe;
    }
  }

  function timeDelta(
    uint256 currentTimeframe,
    uint256 initialTimeframe
  ) public pure returns (uint256) {
    unchecked {
      if (initialTimeframe > currentTimeframe) revert("underflow");
      return currentTimeframe - initialTimeframe;
    }
  }
}
