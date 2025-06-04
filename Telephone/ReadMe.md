# 🎯 Vulnerability Report: Telephone (Ethernaut #4)

## 🔓 Vulnerability  
- **Type**: Improper Authorization (tx.origin vs msg.sender)  
- **Location**: `changeOwner()` function  
- **Root Cause**:  
  The contract uses `tx.origin != msg.sender` for authorization, which can be bypassed by calling through an intermediary contract.
 
## 🕵️‍♂️ How I Discovered It
1. **Looking at the code**:
   - Saw the simple check `tx.origin != msg.sender`
   - Knew this was unsafe from previous learning
   - Noticed no real ownership check

## 💥How the Hack Works
2. **Deploy** a helper contract pointing to the Telephone contract
3. **Call** the attack function from your wallet:
   - Your wallet → Helper contract → Telephone contract
4. **Become owner** because:
   - `tx.origin` = your wallet
   - `msg.sender` = helper contract
   - They're different, so check passes
  

| Call Level               | tx.origin | msg.sender  | Telephone.owner |
|--------------------------|-----------|-------------|-----------------|
| Initial State            | -         | -           | 0xAlice         |
| Eve → attack()           | 0xEve     | 0xEve       | -               |
| attack() → changeOwner() | 0xEve     | 0xAttacker  | -               |
| After execution          | -         | -           | 0xEve           |
