pragma solidity ^0.4.0;
contract Escrow {
    uint public contract_activated_time;
    uint public time_to_raise_dispute;
    address public payer;
    address public payee;
    address public arbitrator;
    uint public amount_payable;
    uint public arbitration_fee;
    bool public activated_by_payee = false;
    bool public activated_by_payer = false;
    bool public contract_activated = false;
    bool public dispute_raised = false;
    bool public contract_settled = false;
    
    function Escrow (
        address _payer, 
        address _payee, 
        address _arbitrator,
        uint _amount_payable, 
        uint _arbitration_fee,
        uint _time_to_raise_dispute
        ) public {
            payee = _payee;
            payer = _payer;
            arbitrator = _arbitrator;
            amount_payable = _amount_payable;
            arbitration_fee = _arbitration_fee;
            time_to_raise_dispute = _time_to_raise_dispute;
        }
    
    function payment_by_payer() public payable {
        //check if amount paid is not less than amount payable
        require(
            msg.value >= (amount_payable+arbitration_fee) && 
            !contract_activated &&
            msg.sender == payer
        );
        uint amount_paid = msg.value;
        uint amount_payable_by_payer = amount_payable+arbitration_fee;
        
        //if paid extra, return that amount
        if (amount_payable_by_payer != amount_paid) {
            uint amount_to_return = amount_paid - amount_payable_by_payer;
            msg.sender.transfer(amount_to_return);
        }
        activated_by_payer = true;
        
        //if contract is activated by both, start the timer and activate the contract
        if(activated_by_payee == true) {
            contract_activated_time  = now;
            contract_activated = true;
        }
    }
    
    function payment_by_payee() public payable {
        require(
            msg.value >= arbitration_fee &&
            !contract_activated &&
            msg.sender == payee
        );
        uint amount_paid = msg.value;
        
        //if paid extra, return that amount
        if (arbitration_fee != amount_paid) {
            uint amount_to_return = amount_paid - arbitration_fee;
            msg.sender.transfer(amount_to_return);
        }
        activated_by_payee = true;
        
        //if contract is activated by both, start the timer and activate the contract
        if(activated_by_payer == true) {
            contract_activated_time  = now;
            contract_activated = true;
        }
    }
    
    
    //withdraw money if other party is taking too much time or any other reason
    function withdraw_by_payer() public{
        require( 
            activated_by_payer &&
            contract_activated == false && 
            msg.sender == payer);
        activated_by_payer = true;
        uint amount_payable_by_payer = amount_payable+arbitration_fee;
        payer.transfer(amount_payable_by_payer);
    }
    
    //withdraw money if other party is taking too much time or any other reason
    function withdraw_by_payee() public{
        require( 
            activated_by_payee &&
            contract_activated == false && 
            msg.sender == payer);
        activated_by_payee = true;
        payer.transfer(arbitration_fee);
    }
    
    
    //called by payee if transaction occured successfully
    function settle() public {
        require(msg.sender == payer);
        payer.transfer(arbitration_fee);
        uint amount_payable_to_payee = arbitration_fee + amount_payable;
        payee.transfer(amount_payable_to_payee);
        contract_settled = true;
    }
    
    //called by anyone(generally payee if time_to_raise_dispute is passed
    function force_settle() public {
        require(now>(time_to_raise_dispute+contract_activated_time));
        payer.transfer(arbitration_fee);
        uint amount_payable_to_payee = arbitration_fee + amount_payable;
        payee.transfer(amount_payable_to_payee);
        contract_settled = true;
    }
    
    function raise_dispute() public {
        require(msg.sender == payer);
        dispute_raised = true;
    }
    
    function pay_to_payee() public {
        require(msg.sender == arbitrator && dispute_raised ==true);
        arbitrator.transfer(arbitration_fee);
        uint amount_payable_to_payee = arbitration_fee + amount_payable;
        payee.transfer(amount_payable_to_payee);
        contract_settled = true;
    }
    
    function pay_to_payer() public {
        require(msg.sender == arbitrator && dispute_raised ==true);
        arbitrator.transfer(arbitration_fee);
        uint amount_payable_to_payer = arbitration_fee + amount_payable;
        payer.transfer(amount_payable_to_payer);
        contract_settled = true;
    }
}
