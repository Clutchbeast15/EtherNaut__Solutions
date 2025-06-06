# 🎯 Vulnerability Report: GatekeeperOne (Ethernaut #13)

## 🔓 Vulnerability  
**Type:** Improper Access Control via Logical Constraints  
**Location:** `enter()` function (GatekeeperOne.sol)  
**Root Cause:**  
- Access control is enforced using three gates (`gateOne`, `gateTwo`, `gateThree`) that can be bypassed with crafted input and gas manipulation.
- Logical constraints in `gateThree` rely on subtle typecasting tricks with `uint64`, `uint32`, and `uint16`, which can be reverse-engineered.
- `gateTwo` relies on gas left modulo a prime number, which is brute-forceable.

---

## 🕵️‍♂️ How Did I Find It?

**Code Review:**  
- `gateOne`: requires `msg.sender != tx.origin` → can be bypassed by calling through a contract.
- `gateTwo`: requires `gasleft() % 8191 == 0` → can be brute-forced.
- `gateThree`: has three conditions involving conversions between `uint64`, `uint32`, and `uint16`.
    - Noticed that `uint32(gateKey) == uint16(gateKey)` → implies 3rd and 4th bytes are zero.
    - Also `uint32(gateKey) == uint16(tx.origin)` → means last 2 bytes of gateKey must match tx.origin.

**Testing:**  
- Crafted a `gateKey` value by hand to satisfy all `gateThree` conditions:
 
  ```js
  bytes8 key = bytes8(uint64(0x1122334400000000) | uint64(lastTwoBytes));
  ```
- Brute-forced gas with loop:
  
  ```js
  for (uint256 i = 0; i < 8191; i++) {
      (success, ) = address(gatekeeper).call{gas: 50000 + i}(
          abi.encodeWithSignature("enter(bytes8)", gateKey)
      );
      if (success) break;
  }
  ```
- Used the test contract as attacker → `msg.sender != tx.origin` ✅
- Verified `gatekeeper.entrant() == tx.origin`

---

## 💥 Exploit Steps

1. Deploy GatekeeperOne contract
2. Calculate `gateKey` that:
   - Ends in last 2 bytes of `tx.origin`
   - Has 3rd and 4th bytes as `0x00`
   - Starts with non-zero high bits
3. Use a brute-force loop to find correct gas offset such that `gasleft() % 8191 == 0`
4. Call `enter(gateKey)` via contract with matched gas
5. Confirm exploit by checking `gatekeeper.entrant() == tx.origin`

---

## 🛡️ Prevention

- Avoid using gas-sensitive constraints like `gasleft() % N` for access control — they are brute-forceable
- Avoid using bitwise type-casting conditions (`uint32 == uint16`) for critical logic — they can be reverse engineered
- Use role-based access control (e.g., `Ownable`, `AccessControl`) instead of clever constraints
- If requiring calls to come from contracts, validate intent via function selectors or signatures

