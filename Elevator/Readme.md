# 🎯 Vulnerability Report: Elevator (Ethernaut #11)

## 🔓 Vulnerability  
**Type**: Logic Flaw + Untrusted Contract Interaction  
**Location**: `Elevator.sol` - `goTo()` function  

**Root Cause**:  
The elevator has two security issues working together:
1. It blindly trusts any Building contract to tell the truth about floor positions
2. It calls `isLastFloor()` twice without checking if the answers match

This lets a hacker trick the elevator by:
- First saying "No, this isn't the top floor" (to get inside)
- Then immediately saying "Yes, this is the top floor" (to lock it forever)

## 🕵️‍♂️ How Did I Find It?  

### Code Review:
1. Saw the contract takes directions from any Building (no ownership check)
2. Noticed it asks `isLastFloor()` twice in the same transaction
3. Realized a smart attacker could give different answers each time

### Testing:
1. Made a test Building that lies:
   - First call: "false" 
   - Second call: "true"
2. Proved the elevator believes both answers, even though they contradict

## 💥 Exploit Steps  

1. Deploy the Attacker Contract

```js
attacker = new MaliciousBuilding(address(elevator));
```
2. Call attack() with any floor number (e.g., 10)

```js
attacker.attack(10);
```
3. That's it! The elevator is now:

Permanently stuck at floor 10

Marked as being at the "top floor" (locked)

🔍 What Happens Automatically:
First isLastFloor() call → returns false (lets elevator move)

Second isLastFloor() call → returns true (locks elevator)

The elevator never moves again!
