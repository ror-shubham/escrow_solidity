# escrow_solidity
Basic Escrow contract

1. There are two parties Alice and Bob, Alice want to buy something from Bob.
2. Following terms are agreed upon-  
  - `abitrator` : address of the arbitrator
  - `amount_payable` : price of good/service
  - `arbitration_fee` : fees to be paid to arbitrator by loosing party in case of dispute
  - `time_to_raise_dispute` : time given to Alice(payer) to raise dispute after activation of contract
3. Alice make the payment for good/service + arbitration fee to the smart-contract using pay `payment_by_payer` function.
4. Bob pay arbitration fee to the smart-contract  using pay `payment_by_payee` function.
5. When both parties pay fees, the contract is activated and a timer starts.
6. If Alice(payer) is satisfied with the delivery, she can settle the contract. The money of good is sent to Bob, and the arbitration fees of respective parties are returned.
7. If Alice doesn't raise dispute in `time_to_raise_dispute`, Bob can call `force_settle` to settle the dispute, and payments are made same as when settled by Alice.
8. If Alice raise dispute in given time, the Arbitrator decides whom to send the money. The arbitration fee of the loosing party in dispute is confisticated and sent to arbitrator. The winner gets the money and his arbitration fee.
 
 
### Potential Problems
 - The arbitrator has no incentive to act honestly
 - The parties need to send the proof of their case using other channels(maybe email, or upload on website hosting front-end)
