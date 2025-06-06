# 🎯 Vulnerability Report: CoinFlip (Ethernaut #3)

## 🔓 Vulnerability  
- **Type**: Predictable Randomness  
- **Location**: `flip()` function  
- **Root Cause**:  
  The contract uses blockchain data (blockhash/block.number) for "randomness", which is publicly visible and predictable within the same transaction.

## 🕵️‍♂️ How Did I Find It?  
1. **Code Review**:  
   - Identified the contract uses `blockhash(block.number - 1)` for randomness
   - Noted it divides by a fixed number (FACTOR = 2²⁵⁵)
   - Realized the same calculation can be replicated by an attacker

2. **Testing**:  
   - Deployed an attacker contract that replicates the calculation
   - Successfully predicted 10/10 flips
   - Verified by checking `consecutiveWins` counter

## 💥 Exploit Steps  
1. Deploy attacker contract with CoinFlip address  
2. For each attempt (10 times):  
   - Get previous block's hash  
   - Divide by FACTOR (2²⁵⁵)  
   - Submit `true` if result == 1, `false` otherwise  
   - Wait for new block between attempts  
3. Verify `consecutiveWins == 10`  

