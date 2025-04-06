# 🎯 Vulnerability Report: Vault (Ethernaut #8)

## 🔓 Vulnerability  
- **Type**: Private Variable Accessibility  
- **Location**: Storage slot access in Ethereum blockchain  
- **Root Cause**:  
  - Misunderstanding of Solidity's `private` visibility modifier
  - Assuming private variables are completely inaccessible
  - Storing sensitive data unencrypted in contract storage

## 🕵️‍♂️ How Did I Find It?  
1. **Code Review**:  
   - Noticed the contract stores a password as `private bytes32`
   - Storing the Password On-Chain Makes it Visible to Anyone vulnerability in my Password Storage vulnerability report ([PasswordStore Review PDF (Page 4)](https://github.com/Clutchbeast15/Updraft-Security-Portfolio/blob/main/Updated-PasswordStore-Review.pdf#page=4))
   

2. **Testing**:  
   - Verified the contract's storage layout using Foundry's `vm.load()`
   - Confirmed password was stored in sequential storage slot (slot 1)
   - Successfully read the private variable directly from storage

## 💥 Exploit Steps  
 1. Deploy Vault with password
 2.  Read storage slot 1 (password)
 3.  Unlock using the retrieved password
 4.  Verify vault is now unlocked   
