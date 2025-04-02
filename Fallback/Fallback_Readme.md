# 🎯 Vulnerability Report: Fallback (Ethernaut #1)

## 🔓 Vulnerability  
- **Type**: Improper `receive()`/`fallback()` Access Control  
- **Location**: `contribute()` and `receive()` functions  
- **Root Cause**:  
  - `receive()` allows ownership takeover with minimal ETH after a tiny `contribute()`.  
  - No minimum `msg.value` check in `receive()`.  

## 🕵️‍♂️ How Did I Find It?  
1. **Code Review**:  
   - Noted `owner` can be changed via `contribute()` **or** `receive()`.  
   - Compared checks:  
     - `contribute()` requires `msg.value < 0.001 ETH`.  
     - `receive()` only needs `contributions[msg.sender] > 0`.  
2. **Testing**:  
   - Sent `0.0001 ETH` via `contribute()`, then `1 wei` to trigger `receive()` → Success!  

## 💥 Exploit Steps  
1. Become a contributor by sending some ETH via contribute()
2. Send ETH directly to trigger the vulnerable fallback function
3. Verify we've become the owner
4. Withdraw funds to prove complete control