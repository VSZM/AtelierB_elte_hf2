/* logic
 * Author: Szegedi Gábor D071PO
 * Creation date: 2018-06-29
 */
MACHINE
    logic
    
SETS
    LOGIC_STATE = {LOGIC_INITIALIZING, LOGIC_A_READ, LOGIC_B_READ, LOGIC_C_CALCULATED, LOGIC_SPECIAL_SEARCH_DONE, LOGIC_COMPLETED}

DEFINITIONS
    "constants.def"

ABSTRACT_VARIABLES
    a, b, c, c_has_special, c_special_index, logic_status
    
INVARIANT
    logic_status : LOGIC_STATE
    & a : 0..arraySize - 1 --> minValue .. maxValue
    & b : 0..arraySize - 1 --> minValue .. maxValue
    & c : 0..arraySize - 1 --> INT
    & c_has_special : BOOL
    & c_special_index : 0..arraySize - 1
    & (logic_status = LOGIC_B_READ => !index.(index : 0..arraySize - 1 => a(index) <= b(index)))
    & (logic_status : {LOGIC_C_CALCULATED, LOGIC_SPECIAL_SEARCH_DONE, LOGIC_COMPLETED} => !index.(index : 0..arraySize - 1 => 19*a(index)-9*b(index)+4 = c(index) ))
    & (logic_status : {LOGIC_SPECIAL_SEARCH_DONE, LOGIC_COMPLETED} & c_has_special = TRUE => (!index.(index : 0..c_special_index - 1 => (0 <= c(index) => not(c(index) mod 32 = 25))) & c(c_special_index) mod 32 = 25))
	& (logic_status : {LOGIC_SPECIAL_SEARCH_DONE, LOGIC_COMPLETED} & c_has_special = FALSE => !index.(index : 0..arraySize - 1 => (0 <= c(index) => not(c(index) mod 32 = 25))))
    
INITIALISATION
    logic_status := LOGIC_INITIALIZING
    || a :: 0..arraySize - 1 --> minValue .. maxValue
    || b :: 0..arraySize - 1 --> minValue .. maxValue
    || c :: 0..arraySize - 1 --> INT
    || c_has_special := FALSE
    || c_special_index := 0
    
OPERATIONS

    init =
        logic_status := LOGIC_INITIALIZING
        || a :: 0..arraySize - 1 --> minValue .. maxValue
        || b :: 0..arraySize - 1 --> minValue .. maxValue
        || c :: 0..arraySize - 1 --> INT
        || c_has_special := FALSE
        || c_special_index := 0
    END;
    
    init_a =
    PRE
      logic_status = LOGIC_INITIALIZING
    THEN
      a :: 0..arraySize - 1 --> minValue .. maxValue
      || logic_status := LOGIC_A_READ
    END;
    
    init_b =
    PRE
      logic_status = LOGIC_A_READ
    THEN
       ANY arr WHERE
          arr : 0..arraySize - 1 --> minValue .. maxValue
          & !index.(index : 0..arraySize - 1 => a(index) <= arr(index))
       THEN
          b := arr
       	  || logic_status := LOGIC_B_READ
       END
    END;
    
    calculate =
    PRE
        logic_status = LOGIC_B_READ
    THEN
       ANY arr WHERE
          arr : 0 .. arraySize - 1 --> INT
          & !index.(index : 0..arraySize - 1 => 19*a(index)-9*b(index)+4 = arr(index) )
       THEN
          c := arr
       	  || logic_status := LOGIC_C_CALCULATED
       END
    END;
    
    search =
    PRE
        logic_status = LOGIC_C_CALCULATED
        & !index.(index : 0..arraySize - 1 => 19*a(index)-9*b(index)+4 = c(index) )
    THEN
       ANY t_found, t_ind WHERE
	      t_found : BOOL
          & t_ind : 0..arraySize - 1
          & (t_found = TRUE => (!index.(index : 0 .. t_ind - 1 => (0 <= c(index) => not(c(index) mod 32 = 25))) & c(t_ind) mod 32 = 25))
          & (t_found = FALSE => !index.(index : 0 .. arraySize - 1 => (0 <= c(index) => not(c(index) mod 32 = 25))))
       THEN
          c_has_special := t_found
          || c_special_index := t_ind
       	  || logic_status := LOGIC_SPECIAL_SEARCH_DONE
       END
    END;
    
    write_result =
    PRE
        logic_status = LOGIC_SPECIAL_SEARCH_DONE
        & !index.(index : 0..arraySize - 1 => 19*a(index)-9*b(index)+4 = c(index) )
        & (c_has_special = TRUE => (!index.(index : 0..c_special_index - 1 => (0 <= c(index) => not(c(index) mod 32 = 25))) & c(c_special_index) mod 32 = 25))
        & (c_has_special = FALSE => !index.(index : 0..arraySize - 1 => (0 <= c(index) => not(c(index) mod 32 = 25))))
    THEN
        logic_status := LOGIC_COMPLETED
    END

END