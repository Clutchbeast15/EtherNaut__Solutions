# 🎯 Vulnerability Report: Force (Ethernaut #7)

## 🔓 Vulnerability
- **Type**: Forced Ether Transfer
- **Location**: Entire contract (no payable/receive functions)
- **Root Cause**:  
  The contract lacks payable functions but can still receive Ether via `selfdestruct` sends, violating its "empty balance" assumption.

 

## 🕵️‍♂️ How Did I Find It?  
1. **Code Review**:  
   - Noticed the contract has no payable functions or receive()/fallback() (empty)
   - Recognized it cannot reject forced Ether via `selfdestruct`

2. **Testing**:  
 - Deployed a sacrificial contract with 1 wei

 - Called selfdestruct(target) pointing to Force contract

 - Verified Force's balance increased despite no payable functions

## 💥 Exploit Steps  
1.  Check initial balance should  be 0
2. Deploy attacker contract with some ether 
3. Forcing Ether via Selfdestruct
4. Verify the balance of force contract            

