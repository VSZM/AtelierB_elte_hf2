/* io
 * Author: Szegedi Gábor D071PO
 * Creation date: 2018-06-29
 */
MACHINE
    io
    
SETS
    IO_STATE = {IO_INITIALIZING, IO_A_READ, IO_B_READ, IO_WRITTEN}

DEFINITIONS
    "constants.def"

ABSTRACT_VARIABLES
    io_status
    
INVARIANT
    io_status : IO_STATE
    
INITIALISATION
    io_status := IO_INITIALIZING
    
OPERATIONS
    a <--read_a =
    PRE
        io_status = IO_INITIALIZING
    THEN
        a :: 0..arraySize - 1 --> minValue .. maxValue
        || io_status := IO_A_READ
    END;
    
    b <--read_b =
    PRE
        io_status = IO_A_READ
    THEN
       ANY arr WHERE
          arr : 0 .. arraySize - 1 --> minValue .. maxValue
        //  & !index.(index : 1..arraySize - 1 => arr(index) <= arr(index))
       THEN
          b := arr
       	  || io_status := IO_B_READ
       END
    END;
    
    write_result(c, special_element_found, special_element_index) =
    PRE
        c : 0..arraySize - 1 --> INT
        & special_element_found : BOOL
        & special_element_index : INT
        & (special_element_found = TRUE => (!index.(index : 0..special_element_index - 1 => (0 <= c(index) => not(c(index) mod 32 = 25))) & c(special_element_index) mod 32 = 25))
        & (special_element_found = FALSE => !index.(index : 0..arraySize - 1 => (0 <= c(index) => not(c(index) mod 32 = 25))))
        & io_status = IO_B_READ
    THEN
        io_status := IO_WRITTEN
    END
END