// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

/// @title LockeDoge ERC20 Token
/// @author 
/// @notice This contract implements the LockeDoge ERC20 token with a fixed total supply.

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        returns (bool);
        
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner, address indexed spender, uint256 value
    );
}

contract ERC20 is IERC20 {
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 private _totalSupply;
    
    mapping(address => uint256) private _balanceOf;
    mapping(address => mapping(address => uint256)) private _allowance;

    constructor(string memory _name, string memory _symbol, uint8 _decimals) {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    // Returns the total token supply
    function totalSupply() external view override returns (uint256) {
        return _totalSupply;
    }

    // Returns the account balance of another account with address `account`
    function balanceOf(address account) external view override returns (uint256) {
        return _balanceOf[account];
    }

    // Transfer the `amount` of tokens to address `recipient`
    function transfer(address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        require(_balanceOf[msg.sender] >= amount, "ERC20: transfer amount exceeds balance");
        _balanceOf[msg.sender] -= amount;
        _balanceOf[recipient] += amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

    // Returns the amount which `spender` is still allowed to withdraw from `owner`
    function allowance(address owner, address spender)
        external
        view
        override
        returns (uint256)
    {
        return _allowance[owner][spender];
    }

    // Allows `spender` to withdraw from your account multiple times, up to the `amount` amount.
    function approve(address spender, uint256 amount) external override returns (bool) {
        _allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // Transfer `amount` tokens from address `sender` to address `recipient`
    function transferFrom(address sender, address recipient, uint256 amount)
        external
        override
        returns (bool)
    {
        require(_balanceOf[sender] >= amount, "ERC20: transfer amount exceeds balance");
        require(_allowance[sender][msg.sender] >= amount, "ERC20: transfer amount exceeds allowance");
        
        _balanceOf[sender] -= amount;
        _balanceOf[recipient] += amount;
        _allowance[sender][msg.sender] -= amount;
        
        emit Transfer(sender, recipient, amount);
        return true;
    }

    // Internal function that mints an amount of the token and assigns it to `account`, increasing the total supply
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: mint to the zero address");
        
        _totalSupply += amount;
        _balanceOf[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    // Internal function that burns an amount of the token from `account`, reducing the total supply
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), "ERC20: burn from the zero address");
        require(_balanceOf[account] >= amount, "ERC20: burn amount exceeds balance");
        
        _balanceOf[account] -= amount;
        _totalSupply -= amount;
        emit Transfer(account, address(0), amount);
    }

    // Public function to mint tokens, restricted to certain roles if needed
    function mint(address to, uint256 amount) external {
        _mint(to, amount);
    }

    // Public function to burn tokens, restricted to certain roles if needed
    function burn(address from, uint256 amount) external {
        _burn(from, amount);
    }
}

contract LockeyDoge is ERC20 {
    uint256 private constant INITIAL_SUPPLY = 1_000_000_000_000 * 10 ** 18;

    constructor()
        ERC20("LockeyDoge", "LDOGE", 18)
    {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}
