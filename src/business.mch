/* logic_i
 * Author: Szegedi Gábor D071PO
 * Creation date: 2018-06-29
 */
MACHINE
    business
DEFINITIONS
    "constants.def"
SETS
    LOGIC_STATE = {LOGIC_INITIALIZING, LOGIC_A_READ, LOGIC_B_READ, LOGIC_C_CALCULATED, LOGIC_SPECIAL_SEARCH_DONE, LOGIC_COMPLETED}
    
ABSTRACT_VARIABLES
    abstract_a_array, abstract_b_array, abstract_c_array, abstract_c_has_special, abstract_c_special_index, abstract_logic_status
    
INVARIANT
    abstract_a_array: minIndex..maxIndex --> minValue..maxValue
    & abstract_b_array: minIndex..maxIndex --> minValue..maxValue 
    & abstract_c_array: minIndex..maxIndex --> INT
    & abstract_c_has_special: BOOL
    & abstract_c_special_index: minIndex..maxIndex
    & abstract_logic_status: LOGIC_STATE
    & (abstract_logic_status: {LOGIC_A_READ} => abstract_a_array: minIndex..maxIndex --> minValue..maxValue)   
    & (abstract_logic_status: {LOGIC_B_READ} => (abstract_b_array: minIndex..maxIndex --> minValue..maxValue
    & !ii.(ii : minIndex..maxIndex-1 => abstract_b_array(ii) > abstract_b_array(ii+1))))
	& (abstract_logic_status: {LOGIC_C_CALCULATED} => (abstract_c_array : minIndex..maxIndex --> INT
	        & !ii.(ii : minIndex..maxIndex => abstract_c_array(ii) =  19*abstract_a_array(ii) + (-9)*abstract_b_array(ii) + 4)))	        
    & (abstract_logic_status : {LOGIC_SPECIAL_SEARCH_DONE} & abstract_c_has_special = TRUE => (!ii.(ii:minIndex..abstract_c_special_index-1 => (0<=abstract_c_array(ii) => not(abstract_c_array(ii) mod 32 = 25))) & abstract_c_array(abstract_c_special_index) mod 32 = 25))
    & (abstract_logic_status : {LOGIC_SPECIAL_SEARCH_DONE} & abstract_c_has_special = FALSE => !ii.(ii:minIndex..maxIndex => (0<=abstract_c_array(ii) => not(abstract_c_array(ii) mod 32 = 25))))
    
    
INITIALISATION
    abstract_a_array := (minIndex..maxIndex) * {minValue}
    || abstract_b_array := (minIndex..maxIndex) * {minValue}
    || abstract_c_array := (minIndex..maxIndex) * {minValue}
    || abstract_c_has_special:= FALSE
    || abstract_c_special_index:= minIndex
    || abstract_logic_status := LOGIC_INITIALIZING
    
OPERATIONS
    init =
    BEGIN
        abstract_a_array := (minIndex..maxIndex) * {minValue}
        || abstract_b_array := (minIndex..maxIndex) * {minValue}
        || abstract_c_array := (minIndex..maxIndex) * {minValue}
        || abstract_c_has_special:= FALSE
    	|| abstract_c_special_index:= minIndex
        || abstract_logic_status := LOGIC_INITIALIZING
    END;
    

    set_a_array =
    PRE
      abstract_logic_status = LOGIC_INITIALIZING
    THEN
      abstract_a_array :: minIndex..maxIndex --> minValue..maxValue
      || abstract_logic_status := LOGIC_A_READ
    END;

    set_b_array =
    PRE
      abstract_logic_status = LOGIC_A_READ
    THEN
      ANY bb
            WHERE
                bb : minIndex..maxIndex --> minValue..maxValue
                & !ii.(ii : minIndex..maxIndex-1 => bb(ii) > bb(ii+1))
            THEN
                abstract_b_array := bb
            END
      || abstract_logic_status := LOGIC_B_READ
    END;
    
    calc =
    PRE
        abstract_logic_status = LOGIC_B_READ
    THEN
        ANY
            vv
        WHERE
            vv: minIndex..maxIndex --> INT
            & !ii.(ii: minIndex..maxIndex => vv(ii) = 19*abstract_a_array(ii) + (-9)*abstract_b_array(ii) + 4)
        THEN
            abstract_c_array := vv
        END
            || abstract_logic_status := LOGIC_C_CALCULATED
    END;
    
    calc_mod=
    PRE
        abstract_logic_status = LOGIC_C_CALCULATED
    THEN
        ANY
            ll, ind
        WHERE
            ll: BOOL
            & ind: minIndex..maxIndex            
            & (ll = TRUE => (!ii.(ii:minIndex..ind-1 => (0<=abstract_c_array(ii) => not(abstract_c_array(ii) mod 32 = 25))) & abstract_c_array(ind) mod 32 = 25))
    & (ll = FALSE => !ii.(ii:minIndex..maxIndex => (0<=abstract_c_array(ii) => not(abstract_c_array(ii) mod 32 = 25))))
         THEN
             abstract_c_has_special:= ll
             || abstract_c_special_index:= ind
             || abstract_logic_status:= LOGIC_SPECIAL_SEARCH_DONE
         END
     END
     ;
   
    write_result =
    PRE
        abstract_logic_status = LOGIC_SPECIAL_SEARCH_DONE
    THEN
        abstract_logic_status := LOGIC_COMPLETED
    END

END
