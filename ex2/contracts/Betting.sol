pragma solidity ^0.4.15;

contract Betting {
	/* Standard state variables */
	address public owner;
	address public gamblerA;
	address public gamblerB;
	address public oracle;
	uint[] outcomes;	// Feel free to replace with a mapping

	/* Structs are custom data structures with self-defined parameters */
	struct Bet {
		uint outcome;
		uint amount;
		bool initialized;
	}

	/* Keep track of every gambler's bet */
	mapping (address => Bet) bets;
	/* Keep track of every player's winnings (if any) */
	mapping (address => uint) winnings;

	/* Add any events you think are necessary */
	event BetMade(address gambler);
	event BetClosed();

	/* Uh Oh, what are these? */
	modifier OwnerOnly() {
	    require(msg.sender == owner);
	    _;}
	modifier OracleOnly() {
	    require(msg.sender == oracle);
	    _;}

	/* Constructor function, where owner and outcomes are set */
	function BettingContract(uint[] _outcomes) {
	    owner = msg.sender;
	    outcomes = _outcomes;
	}

	/* Owner chooses their trusted Oracle */
	function chooseOracle(address _oracle) OwnerOnly() returns (address) {
	    oracle = _oracle;
	    return _oracle;
	}

	/* Gamblers place their bets, preferably after calling checkOutcomes */
	function makeBet(uint _outcome, uint _amount) payable returns (bool) {
	    require(msg.sender != owner && msg.sender != oracle);
	    if (gamblerA == 0) {
	        gamblerA = msg.sender;
	        Bet storage a;
	        a.outcome = _outcome;
	        a.amount = _amount;
	        a.initialized = true;
	        winnings[msg.sender] += 0;
	        bets[msg.sender] = a;
	        BetMade(msg.sender);
	        return true;
	        
	    } else if (gamblerB == 0) {
	        gamblerB = msg.sender;
	        Bet storage b;
	        b.outcome = _outcome;
	        b.amount = _amount;
	        b.initialized = true;
	        
	        
	        bets[msg.sender] = b;
	        winnings[msg.sender] += 0;
	        BetMade(msg.sender);
	        return true;
	    }
	    
	    return false;
	}

	/* The oracle chooses which outcome wins */
	function makeDecision(uint _outcome) OracleOnly() {
	    uint outcome = _outcome;
	    if (bets[gamblerA].outcome == outcome && bets[gamblerB].outcome == outcome) {
	    } else {
	        if (bets[gamblerA].outcome == outcome) {
	            winnings[gamblerA] += (bets[gamblerA].amount + bets[gamblerB].amount);
	        } else if (bets[gamblerB].outcome == outcome) {
	            winnings[gamblerB] += (bets[gamblerB].amount + bets[gamblerA].amount);
	        } else {
	            winnings[oracle] += (bets[gamblerA].amount + bets[gamblerB].amount);
	        }
	    }
	    gamblerA = 0;
	    delete bets[gamblerA];
	    gamblerB = 0;
	    delete bets[gamblerB];
	    BetClosed();
	    
	}

	/* Allow anyone to withdraw their winnings safely (if they have enough) */
	function withdraw(uint withdrawAmount) returns (uint remainingBal) {
	    if (winnings[msg.sender] >= withdrawAmount){
	        winnings[msg.sender] -= withdrawAmount;
	    }
	    return winnings[msg.sender];
	    
	}
	
	/* Allow anyone to check the outcomes they can bet on */
	function checkOutcomes() constant returns (uint[]) {
	    return outcomes;
	}
	
	/* Allow anyone to check if they won any bets */
	function checkWinnings() constant returns(uint) {
	    return winnings[msg.sender];
	}

	/* Call delete() to reset certain state variables. Which ones? That's upto you to decide */
	function contractReset() private {
	}

	/* Fallback function */
	function() payable {
		revert();
	}
}