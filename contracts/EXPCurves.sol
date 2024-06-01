// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {exp} from "@prb/math/src/sd59x18/Math.sol";
import {wrap, unwrap} from "@prb/math/src/sd59x18/Casting.sol";

/**
 * @title Exponential Curves
 * @author https://github.com/0xneves
 * @notice This smart contract implements an advanced exponential curve formula designed to
 * handle various time-based events such as token vesting, game mechanics, unlock schedules,
 * and other timestamp-dependent actions. The core functionality is driven by an exponential
 * curve formula that allows for smooth, nonlinear transitions over time, providing a more
 * sophisticated and flexible approach compared to linear models.
 */
abstract contract EXPCurves {
  /**
   * @notice The initial timeframe is invalid.
   *
   * Requirements:
   *
   * - Must be less than or equal to the current timestamp
   * - Must be less than the final timestamp.
   */
  error EXPCurveInvalidInitialTimeframe();
  /**
   * @notice The curvature factor is invalid.
   *
   * Requirements:
   *
   * - It cannot be zero
   * - Cannot be bigger than type uint of value 133 while using regular unix timestamps
   * as inputs, or it blows up the emulator. Thus it is capped at int8 or 127.
   *
   * NOTE: For negative values it can go way further than type int of value -133, but there
   * is no need to go that far.
   */
  error EXPCurveInvalidCurvature();

  /**
   * @dev This function calculates the exponential decay value over time.
   *
   * This formula ensures that the value starts at 100%/0% at the beginning (t0)
   * and decreases/increases to 0%/100% at the end (T), following an exponential decay curve.
   *
   * The formula used for the curves difers based on the `ascending` parameter:
   *
   * ascending = ((exp(k * (1 - (t - t0) / (T - t0))) - 1) / (exp(k) - 1)) * 100
   * descenging = ((exp(k * ((t - t0) / (T - t0))) - 1) / (exp(k) - 1)) * 100
   *
   * Where:
   * - t is the current timestamp
   * - t0 is the start timestamp
   * - T is the end timestamp
   * - k is the curvature factor, determining the steepness of the curve
   * - exp() is the exponential function with base 'E' (Euler's number, approximately 2.71828)
   *
   * Requirements:
   *
   * - The initial timestamp must be less than or equal to the current timestamp
   * - The initial timestamp must be less than the final timestamp
   * - The curvature cannot be zero
   *
   * NOTE: To avoid precision issues, the formula uses fixed-point math with 18 decimals.
   * When returning this function result, make sure to adjust the output values accordingly.
   *
   * NOTE: Using type uint32 for timestamps since 4294967295 unix seconds will only overflow
   * in the year 2106, which is more than enough for the current use cases.
   *
   * @param currentTimeframe The current timestamp or a point within the spectrum
   * @param initialTimeframe The initial timestamp or the beginning of the curve
   * @param finalTimeframe The final timestamp or the end of the curve
   * @param curvature The curvature factor. Determines the steepness of the curve and can be
   * negative, which will invert the curve's direction.
   * @param ascending The curve direction (ascending or descending)
   * @return int256 The exponential decay value at a specific interval
   */
  function expcurve(
    uint32 currentTimeframe,
    uint32 initialTimeframe,
    uint32 finalTimeframe,
    int8 curvature,
    bool ascending
  ) public pure virtual returns (int256) {
    if (initialTimeframe > currentTimeframe)
      revert EXPCurveInvalidInitialTimeframe();
    if (initialTimeframe >= finalTimeframe)
      revert EXPCurveInvalidInitialTimeframe();
    if (curvature == 0) revert EXPCurveInvalidCurvature();
    if (currentTimeframe > finalTimeframe) {
      return ascending ? int(0) : int(100 * 1e18);
    }
    // Calculate the Time Delta and Total Time Interval
    int256 td = int(uint256(currentTimeframe - initialTimeframe));
    int256 tti = int(uint256(finalTimeframe - initialTimeframe));

    // Calculate the Time Elapsed Ratio
    int256 ter = unwrap(wrap(td) / wrap(tti));
    int256 cs; // Curve Scaling
    if (ascending) {
      cs = curvature * int(ter);
    } else {
      cs = curvature * (1e18 - int(ter));
    }

    // Calculate the Exponential Decay
    int256 expo = unwrap(exp(wrap(cs))) - 1e18;
    // Calculate the Final Exponential Scaling
    int256 fes = unwrap(exp(wrap(int(curvature) * 1e18))) - 1e18;

    // Normalize the Exponential Decay
    return unwrap(wrap(expo) / wrap(fes)) * 100;
  }
}
