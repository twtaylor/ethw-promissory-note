# Goals / Motivation

The goal of this exercise is to create an ERC20 token that represents a claim on ETHw post-merge. This can be used as an on-chain price-discovery mechanism until the Merge.

# Design 

1) User deposits ETH (everything gets converted into WETH) pre-merge (`mint()`). Alternatively, user deposits WETH after `approve()` is called on this contract.
2) User receives an ERC20 token, we'll call it ETHw-PN
3) This user's address is recorded in `originalOwnerNotes`
4) This token represents pre-merge:

- chain: 1 - The ETH that has been deposited is wholly unrecoverable until post-merge.
- ERC20 token - The ERC20 token is now tradeable.

4) But post-merge...

- chain: 1 - The contract can be called by the original minter for WETH to be sent back forward to an `address to`.
- chain: 1001 - The ERC20 token can be redeemed for the balance of WETH in the contract.
 
# Legal

Licensed under the Apache License, Version 2.0 (the "License"); you may not use these file(s) except in compliance with the License. You may obtain a copy of the License at http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.