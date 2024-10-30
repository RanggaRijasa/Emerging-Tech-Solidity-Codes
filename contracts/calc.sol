// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.26 and less than 0.9.0
pragma solidity ^0.8.26;

contract Calculator {
    int256 public lastResult;

    function add(int256 a) public{
        lastResult += a;

    }

    function subtract(int256 a) public{
        lastResult -= a;

    }

    function multiply(int256 a) public{
        lastResult *= a;
    }

    function divide(int256 a) public{
        require(a != 0, "Division by zero is not allowed");
        lastResult /= a;
    }

    function power(uint256 exponent) public returns (int256) {
        lastResult = int256(uint256(lastResult) ** exponent);
        return lastResult;
    }

    function root(uint256 n) public returns (int256) {
        require(lastResult >= 0, "Cannot take root of a negative number");
        lastResult = int256(nthRoot(uint256(lastResult), n));
        return lastResult;
    }

    function modulo(int256 a) public returns (int256) {
        lastResult %= a;
        return lastResult;
    }

    function factorial() public returns (int256) {
        require(lastResult >= 0, "Factorial of negative number is not allowed");
        lastResult = int256(fact(uint256(lastResult)));
        return lastResult;
    }

    function clear() public {
        lastResult = 0;
    }

    function fact(uint256 n) internal pure returns (uint256) {
        if (n == 0) {
            return 1;
        } else {
            return n * fact(n - 1);
        }
    }

    function nthRoot(uint256 x, uint256 n) internal pure returns (uint256) {
        uint256 z = (x + n) / 2;
        uint256 y = x;
        while (z < y) {
            y = z;
            z = (x / z + z) / 2;
        }
        return y;
    }
}
