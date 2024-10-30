// SPDX-License-Identifier: MIT
// compiler version must be greater than or equal to 0.8.26 and less than 0.9.0
pragma solidity ^0.8.26;

contract HelloWorld {
    string public greet = "Hello World!";
    uint256 private age = 10;

    function getGreet() private view returns (string memory)
    {
        return  greet;
    }

    function setGreetandAge(string memory _greet, uint256 _age) public 
    {
        greet = _greet;
        age = _age;
    }
}