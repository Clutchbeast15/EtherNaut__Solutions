# 🎯 Vulnerability Report: Token (Ethernaut #5)

## 🔓 Vulnerability  
- **Type**: Integer Underflow  
- **Location**: `transfer()` function  
- **Root Cause**:  
  - Uses Solidity 0.6.0 without SafeMath  
  - No overflow/underflow protection in arithmetic operations  
  - Allows balance to underflow when transferring more than current balance  

## 🕵️‍♂️ How Did I Find It?  
1. **Code Review**:  
   - Saw the contract uses Solidity 0.6.0 → Older versions don’t automatically stop invalid math (like negative balances).
   - Noticed the transfer() function doesn’t check if you have enough tokens before sending.
   - Checked `balanceOf` uses `uint256` which can underflow  
2. **Testing**:  
   - Initial balance: 20 tokens  
   - Attempted transfer of 21 tokens → Balance became `2²⁵⁶-1`  
   - Verified with `balanceOf()` check  

## 💥 Exploit Steps  
1. Check initial balance (should be 20 tokens)  
2. Transfer 21 tokens to any address (force underflow)  
3. Verify balance underflowed to max uint256 value  
  

## 🛡️ Prevention  
1. Use Solidity 0.8.0+ with built-in overflow checks  
2. Implement SafeMath library for older versions  
3. Add require(balance >= amount) before transfers  
