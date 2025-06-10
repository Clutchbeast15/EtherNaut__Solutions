# 🎯 Vulnerability Report: GatekeeperTwo (Ethernaut #14)

---

## 🔓 Vulnerability

- **Type**: Improper Access Control (Bypass using constructor timing and hash manipulation)
- **Location**: `GatekeeperTwo.enter()` function
- **Root Cause**: 
  - Use of **`extcodesize(msg.sender)`** to block contracts → bypassed by constructor execution.
  - Misuse of **hash-based XOR** gate → predictable if you control the `msg.sender`.

---

## 🕵️‍♂️ How Did I Find It?

### 1. **Code Review**
- Spotted three gates enforcing strict conditions on the caller:
  1. `msg.sender != tx.origin`
  2. XOR-based key derived from `msg.sender`
  3. `extcodesize(msg.sender) == 0` for EOA → revealed a known constructor bypass

- Observed the XOR gate can be solved algebraically if you can control `msg.sender`.

---
### 2. **Testing and Bypassing All Gates**
 
1️⃣ Gate 1: msg.sender != tx.origin
        
- msg.sender here = this contract address (address(this))
- tx.origin = attacker (EOA)
- → DIFFERENT → ✅ Gate 1 passed
        
2️⃣Gate 2: extcodesize(msg.sender) == 0
       
- extcodesize(address(this)) returns 0 → because contract is not deployed yet during constructor
 → ✅ Gate 2 passed
       
 3️⃣Gate 3: 
 ```js
  uint64(bytes8(keccak256(abi.encodePacked(msg.sender)))) ^ uint64(_gateKey) == type(uint64).max
  ```

- Need to solve for _gateKey → rearranged as:
```js
        _gateKey = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max)
```
- address(this) = the address of THIS attacking contract → must be used for correct hash
→ ✅ Gate 3 passed
      

        
        


---

## 💥 Exploit Steps


1. Deploy an attack contract from an EOA (to satisfy tx.origin == EOA).

2. In the constructor of the attack contract:
   
- Calculate `_gateKey` → using:
      `_gateKey = bytes8(uint64(bytes8(keccak256(abi.encodePacked(address(this))))) ^ type(uint64).max);`

- Call `enter(_gateKey)` on the GatekeeperTwo contract.

3. During constructor execution → `extcodesize(address(this))` == `0` → passes Gate 2.

4. Since `msg.sender `= `contract address ≠ tx.origin` → passes Gate 1.

5. XOR-based check passes due to the key calculation → passes Gate 3.


