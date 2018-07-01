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
    abstract_a_array, abstract_b_array, abstract_c_array, c_has_special, c_special_index, logic_status
    
INVARIANT
    logic_status : LOGIC_STATE
    & abstract_a_array : 0..arraySize - 1 --> minValue .. maxValue
    & abstract_b_array : 0..arraySize - 1 --> minValue .. maxValue
    & abstract_c_array : 0..arraySize - 1 --> INT
    
    & c_has_special : BOOL
    & c_special_index : 0..arraySize - 1
    & (logic_status : {LOGIC_C_CALCULATED, LOGIC_SPECIAL_SEARCH_DONE, LOGIC_COMPLETED} => !index.(index : 0..arraySize - 1 =>  19*abstract_a_array(index) + (-9)*abstract_b_array(index) + 4 = abstract_c_array(index) ))
    & (logic_status : {LOGIC_SPECIAL_SEARCH_DONE, LOGIC_COMPLETED} & c_has_special = TRUE => (!index.(index : 0..c_special_index - 1 => (0 <= abstract_c_array(index) => not(abstract_c_array(index) mod 32 = 25))) & abstract_c_array(c_special_index) mod 32 = 25))
	& (logic_status : {LOGIC_SPECIAL_SEARCH_DONE, LOGIC_COMPLETED} & c_has_special = FALSE => !index.(index : 0..arraySize - 1 => (0 <= abstract_c_array(index) => not(abstract_c_array(index) mod 32 = 25))))
    
INITIALISATION
    logic_status := LOGIC_INITIALIZING
    || abstract_a_array :: 0..arraySize - 1 --> minValue .. maxValue
    || abstract_b_array :: 0..arraySize - 1 --> minValue .. maxValue
    || abstract_c_array :: 0..arraySize - 1 --> INT
    || c_has_special := FALSE
    || c_special_index := 0
    
OPERATIONS

    init =
    BEGIN
        logic_status := LOGIC_INITIALIZING 
        || abstract_a_array :: 0..arraySize - 1 --> minValue .. maxValue
        || abstract_b_array :: 0..arraySize - 1 --> minValue .. maxValue
        || abstract_c_array :: 0..arraySize - 1 --> INT
        || c_has_special := FALSE
        || c_special_index := 0
    END;
    
    init_a =
    PRE
      logic_status = LOGIC_INITIALIZING
    THEN
      abstract_a_array :: 0..arraySize - 1 --> minValue .. maxValue
      || logic_status := LOGIC_A_READ
    END;
    
    init_b =
    PRE
      logic_status = LOGIC_A_READ
    THEN
      abstract_b_array :: 0..arraySize - 1 --> minValue .. maxValue
   	  || logic_status := LOGIC_B_READ
    END;
    
    calculate =
    PRE
        logic_status = LOGIC_B_READ
    THEN
       ANY arr WHERE
          arr : 0 .. arraySize - 1 --> INT
          & !index.(index : 0..arraySize - 1 =>  19*abstract_a_array(index) + (-9)*abstract_b_array(index) + 4 = arr(index) )
       THEN
          abstract_c_array := arr
       	  || logic_status := LOGIC_C_CALCULATED
       END
    END;
    
    search =
    PRE
        logic_status = LOGIC_C_CALCULATED
        & !index.(index : 0..arraySize - 1 =>  19*abstract_a_array(index) + (-9)*abstract_b_array(index) + 4 = abstract_c_array(index) )
    THEN
       ANY t_found, t_ind WHERE
	      t_found : BOOL
          & t_ind : 0..arraySize - 1
          & (t_found = TRUE => (!index.(index : 0 .. t_ind - 1 => (0 <= abstract_c_array(index) => not(abstract_c_array(index) mod 32 = 25))) & abstract_c_array(t_ind) mod 32 = 25))
          & (t_found = FALSE => !index.(index : 0 .. arraySize - 1 => (0 <= abstract_c_array(index) => not(abstract_c_array(index) mod 32 = 25))))
       THEN
          c_has_special := t_found
          || c_special_index := t_ind
       	  || logic_status := LOGIC_SPECIAL_SEARCH_DONE
       END
    END;
    
    write_result =
    PRE
        logic_status = LOGIC_SPECIAL_SEARCH_DONE
        & !index.(index : 0..arraySize - 1 =>  19*abstract_a_array(index) + (-9)*abstract_b_array(index) + 4 = abstract_c_array(index) )
        & (c_has_special = TRUE => (!index.(index : 0..c_special_index - 1 => (0 <= abstract_c_array(index) => not(abstract_c_array(index) mod 32 = 25))) & abstract_c_array(c_special_index) mod 32 = 25))
        & (c_has_special = FALSE => !index.(index : 0..arraySize - 1 => (0 <= abstract_c_array(index) => not(abstract_c_array(index) mod 32 = 25))))
    THEN
        logic_status := LOGIC_COMPLETED
    END

END