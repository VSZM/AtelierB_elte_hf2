/* ui
 * Author: Szegedi Gábor D071PO
 * Creation date: 2018-06-29
 */
MACHINE
    ui
DEFINITIONS
    "constants.def"

SETS
    S_UI_STATUS = {UI_INIT, UI_A_IS_READ, UI_B_IS_READ, UI_RES_IS_WRITTEN}
    
VARIABLES
    ui_status
    
INVARIANT
    ui_status : S_UI_STATUS
    
INITIALISATION
    ui_status := UI_INIT
    
OPERATIONS
    ui_init = ui_status := UI_INIT;
    

    ret <--read_a_array =
    PRE
        ui_status = UI_INIT
    THEN
        ret :: minIndex..maxIndex --> minValue..maxValue
        || ui_status := UI_A_IS_READ
    END;

    ret <--read_b_array =
    PRE
        ui_status = UI_A_IS_READ
    THEN
        ANY bb
            WHERE
                bb : minIndex .. maxIndex --> minValue..maxValue
                & !ii.(ii : minIndex .. maxIndex-1 => bb(ii) > bb(ii+1))
            THEN
                ret := bb
        END    
        || ui_status := UI_B_IS_READ
    END;

    write_result(p_res, mod_ll, mod_ind) =
    PRE
        p_res : minIndex .. maxIndex --> INT
        & mod_ll :BOOL
        & mod_ind : minIndex .. maxIndex
        & ui_status = UI_B_IS_READ
    THEN
        ui_status := UI_RES_IS_WRITTEN
    END
END

