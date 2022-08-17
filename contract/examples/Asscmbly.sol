// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Assembly{

    function addT(uint x, uint y) public pure returns (uint) {
        assembly{
            let result := add(x, y)
            mstore(0x00, result)  // mstore(p, v)   ->  mem[p...(p + 32)) := v
            return(0x00, 32)  
        }
    }

    function contextT(uint a) public pure {
        
        assembly{ let x := 2 }

        assembly{ let x := 22 }

        assembly{ let x := add(a, 2) }

        assembly{ let x := a }

        assembly{ 
            let x    // default = 0 
            x := 22
        }

        assembly{ 
            let x := 5
            let z := add(keccak256(0x0, 0x20), div(x, 32))

            {
                let y := x 
            } // destroy y vaiable here
        }
    }

    function loopTV1(uint n, uint value) public pure returns(uint) {
        for(uint i=0; i<n; i++){
            value = 2*value;
        }
        return value;
    }
    // use assembly lauguage to rewrite like above 
    function loopTV2(uint n, uint value) public pure returns(uint) {
        assembly{
            for{let i := 0} lt(i, n) { i := add(i, 1) }{
                value := mul(2, value)
            }
            mstore(0x0, value)
            return(0x0, 32)
        }
    }

    function loopW() public{
        assembly{
            let x:=0
            let i:=0
            for{} lt(i, 0x100) {}{   // same as  `while(i < 0x100)` 
                x:=add(x, mload(i))
                // x:=add(x, i)  // why canot use i directly ? 
                i:= add(i, 0x20)
            }
        }


        // how to use  `if` 
        assembly{
            let x:=2
            if slt(x, 0) { x := sub(0, x) }

            let value := 3
            // if eq(value, 0) revert(0, 0)  // need { }
            if eq(value, 0)  { revert(0, 0)}  // thats ok
        }

        // how to use `swith`
        assembly{
            let x:=0
            switch calldataload(4)
            case 0{
                x:= calldataload(0x24)
            }
            default{
                x:= calldataload(0x44)
            }
            sstore(0, div(x,2))
        }

        // how to define `function` at inline assembly
        assembly{
            function allocate(length) -> pos{
                pos := mload(0x40)
                mstore(0x40, add(pos, length))
            }

            let free_memory_pointer := allocate(64)
        }
    }
}

