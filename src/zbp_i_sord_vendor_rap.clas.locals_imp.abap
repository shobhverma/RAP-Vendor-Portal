CLASS lcl_buffer DEFINITION.
PUBLIC SECTION.
*** Declaration
TYPES: BEGIN OF ty_buffer_ord.
 INCLUDE TYPE zsord_vendor_RAP AS data.
TYPES: flag TYPE c LENGTH 1,
END OF ty_buffer_ord.
TYPES: tt_buffer_ord TYPE STANDARD TABLE OF ty_buffer_ord.
CLASS-DATA mt_buffer_ord TYPE tt_buffer_ord.
ENDCLASS.
CLASS lhc_Vendor DEFINITION INHERITING FROM cl_abap_behavior_handler.
PRIVATE SECTION.
METHODS create FOR MODIFY
IMPORTING entities FOR CREATE Vendor.
METHODS delete FOR MODIFY
IMPORTING keys FOR DELETE Vendor.
METHODS update FOR MODIFY
IMPORTING entities FOR UPDATE Vendor.

METHODS lock FOR LOCK
IMPORTING keys FOR LOCK Vendor.
METHODS read FOR READ
IMPORTING keys FOR READ Vendor RESULT result.
METHODS set_status FOR MODIFY
IMPORTING keys FOR ACTION Vendor~set_status RESULT result.
METHODS get_features FOR FEATURES
IMPORTING keys REQUEST requested_features FOR Vendor RESULT result.
ENDCLASS.
CLASS lhc_Vendor IMPLEMENTATION.
METHOD create.
*** Create data
DATA ls_failed LIKE LINE OF reported-vendor.
LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_entities>).
IF <lfs_entities>-VendorId IS INITIAL. "check for vendor id
APPEND VALUE #(
%cid = <lfs_entities>-%cid
%create = if_abap_behv=>mk-on
) TO failed-vendor.
ls_failed-%cid = <lfs_entities>-%cid.
ls_failed-%element-sord = if_abap_behv=>mk-on.
ls_failed-%msg = new_message( id = 'ZRAP6'
number = 000
severity = if_abap_behv_message=>severity-error
).
APPEND ls_failed TO reported-vendor.
ELSEIF <lfs_entities>-CustomerId IS INITIAL. "check for customer id
APPEND VALUE #(
%cid = <lfs_entities>-%cid
%create = if_abap_behv=>mk-on
) TO failed-vendor.
ls_failed-%cid = <lfs_entities>-%cid.
ls_failed-%element-sord = if_abap_behv=>mk-on.
ls_failed-%msg = new_message( id = 'ZRAP6'
number = 001
severity = if_abap_behv_message=>severity-error
).
APPEND ls_failed TO reported-vendor.

ELSE.
*** Save the data
GET TIME STAMP FIELD DATA(lv_tsl).
*** Get last saved sales order
SELECT MAX( sord ) FROM zsord_vendor_RAP INTO @DATA(lv_max_sord).
lv_max_sord = lv_max_sord + 1. "increment by 1
SHIFT lv_max_sord LEFT DELETING LEADING space.
APPEND INITIAL LINE TO lcl_buffer=>mt_buffer_ord ASSIGNING FIELD-SYMBOL(<buffer>).
<buffer> = CORRESPONDING #( <lfs_entities> ).
<buffer>-sord = lv_max_sord.
<buffer>-createdat = lv_tsl.
<buffer>-createdby = sy-uname.
<buffer>-flag = 'C'. "created
INSERT VALUE #( %cid = <lfs_entities>-%cid sord = lv_max_sord ) INTO TABLE mapped-vendor.
ENDIF.
ENDLOOP.
ENDMETHOD.
METHOD delete.
LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_delete>).
IF <lfs_delete>-sord IS NOT INITIAL.
INSERT VALUE #( sord = <lfs_delete>-sord ) INTO TABLE mapped-vendor.
APPEND INITIAL LINE TO lcl_buffer=>mt_buffer_ord ASSIGNING FIELD-SYMBOL(<buffer>).
<buffer>-sord = <lfs_delete>-Sord.
<buffer>-flag = 'D'. "delete
INSERT VALUE #( sord = <lfs_delete>-sord ) INTO TABLE mapped-vendor.
ENDIF.
ENDLOOP.
ENDMETHOD.
METHOD update.
DATA ls_failed LIKE LINE OF reported-vendor.
LOOP AT entities ASSIGNING FIELD-SYMBOL(<lfs_new_data>).
APPEND INITIAL LINE TO lcl_buffer=>mt_buffer_ord ASSIGNING FIELD-SYMBOL(<lfs_buffer>).
SELECT SINGLE * FROM zsord_vendor_RAP WHERE sord = @<lfs_new_data>-Sord
INTO @DATA(ls_old_data) .
IF sy-subrc EQ 0.
<lfs_buffer> = CORRESPONDING #( ls_old_data ).
<lfs_buffer>-flag = 'U'. "update
*** Customer id
IF ( ( <lfs_new_data>-CustomerId <> ls_old_data-customerid ) AND

<lfs_new_data>-CustomerId <> ' ' ).
<lfs_buffer>-customerid = <lfs_new_data>-CustomerId.
*** Vendor id
ELSEIF ( ( <lfs_new_data>-vendorid <> ls_old_data-vendorid ) AND
<lfs_new_data>-vendorid <> ' ' ).
<lfs_buffer>-vendorid = <lfs_new_data>-vendorid.
*** Delivery country
ELSEIF ( ( <lfs_new_data>-deliverycountry <> ls_old_data-deliverycountry ) AND
<lfs_new_data>-deliverycountry <> ' ' ).
<lfs_buffer>-deliverycountry = <lfs_new_data>-deliverycountry.
*** Description
ELSEIF ( ( <lfs_new_data>-description <> ls_old_data-description ) AND
<lfs_new_data>-description <> ' ' ).
<lfs_buffer>-description = <lfs_new_data>-description.
*** Overall status
ELSEIF ( ( <lfs_new_data>-overallstatus <> ls_old_data-overallstatus ) AND
<lfs_new_data>-overallstatus <> ' ' ).
<lfs_buffer>-overallstatus = <lfs_new_data>-overallstatus.
*** Order confirmation Date
ELSEIF ( ( <lfs_new_data>-orderconfdate <> ls_old_data-orderconfdate ) AND
<lfs_new_data>-orderconfdate <> ' ' ).
<lfs_buffer>-orderconfdate = <lfs_new_data>-orderconfdate.
*** Delivery Date
ELSEIF ( ( <lfs_new_data>-deliverydate <> ls_old_data-deliverydate ) AND
<lfs_new_data>-deliverydate <> ' ' ).
<lfs_buffer>-deliverydate = <lfs_new_data>-deliverydate.
*** Remarks
ELSEIF ( ( <lfs_new_data>-remarks <> ls_old_data-remarks ) AND
<lfs_new_data>-remarks <> ' ' ).
<lfs_buffer>-remarks = <lfs_new_data>-remarks.
ENDIF.
ENDIF.
<lfs_buffer>-lastchangedby = sy-uname.
GET TIME STAMP FIELD DATA(lv_tsl).
<lfs_buffer>-lastchangedat = lv_tsl. "last changed on
ENDLOOP.
ENDMETHOD.

METHOD lock.
ENDMETHOD.
METHOD read.
*** Get already saved data
LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
SELECT * FROM zsord_vendor_RAP WHERE sord = @<lfs_keys>-Sord INTO TABLE @DATA(lt_result_tmp) .
result = VALUE #( FOR ls_result_tmp IN lt_result_tmp
( sord = ls_result_tmp-sord
customerid = ls_result_tmp-customerid
vendorid = ls_result_tmp-vendorid
deliverycountry = ls_result_tmp-deliverycountry
description = ls_result_tmp-description
overallstatus = ls_result_tmp-overallstatus
OrderConfDate = ls_result_tmp-orderconfdate
DeliveryDate = ls_result_tmp-deliverydate
Remarks = ls_result_tmp-remarks
createdby = ls_result_tmp-createdby
createdat = ls_result_tmp-createdat
lastchangedby = ls_result_tmp-lastchangedby
LastChangedAt = ls_result_tmp-lastchangedat
) ).
ENDLOOP.
ENDMETHOD.
METHOD set_status.
*** Set "Release Status" field
GET TIME STAMP FIELD DATA(lv_tsl).
LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
APPEND INITIAL LINE TO result ASSIGNING FIELD-SYMBOL(<lfs_result>).
SELECT * FROM zsord_vendor_RAP WHERE sord = @<lfs_keys>-Sord INTO TABLE @DATA(lt_result_tmp) .
IF sy-subrc EQ 0.
LOOP AT lt_result_tmp ASSIGNING FIELD-SYMBOL(<lfs_olddata>).
APPEND INITIAL LINE TO lcl_buffer=>mt_buffer_ord ASSIGNING FIELD-SYMBOL(<lfs_buffer>).
<lfs_result>-Sord = <lfs_olddata>-sord.
<lfs_result>-%param = CORRESPONDING #( <lfs_olddata> ).
<lfs_buffer> = CORRESPONDING #( <lfs_olddata> ).
<lfs_buffer>-overallstatus = 'R'. "released
<lfs_buffer>-lastchangedby = sy-uname.
<lfs_buffer>-lastchangedat = lv_tsl.
<lfs_buffer>-flag = 'U'. "update
ENDLOOP.
ENDIF.
ENDLOOP.

ENDMETHOD.
METHOD get_features.
*** Enable/Disable rows based on Overall Status
DATA: ls_result LIKE LINE OF result.
LOOP AT keys ASSIGNING FIELD-SYMBOL(<lfs_keys>).
SELECT SINGLE * FROM zsord_vendor_RAP WHERE sord = @<lfs_keys>-Sord INTO @DATA(ls_result_tmp) .
ls_result-%key = <lfs_keys>-Sord.
ls_result-%features-%action-set_status = COND #( WHEN ls_result_tmp-overallstatus = 'R'
THEN if_abap_behv=>fc-o-disabled ELSE if_abap_behv=>fc-o-enabled )
.
APPEND ls_result TO result.
ENDLOOP.
ENDMETHOD.
ENDCLASS.
CLASS lsc_ZI_SORD_VENDOR_RAP DEFINITION INHERITING FROM cl_abap_behavior_saver.
PROTECTED SECTION.
METHODS check_before_save REDEFINITION.
METHODS finalize REDEFINITION.
METHODS save REDEFINITION.
ENDCLASS.
CLASS lsc_ZI_SORD_VENDOR_RAP IMPLEMENTATION.
METHOD check_before_save.
ENDMETHOD.
METHOD finalize.
ENDMETHOD.
METHOD save.
*** Save data
DATA: lt_data_cr TYPE STANDARD TABLE OF zsord_vendor_RAP,
lt_data_del TYPE STANDARD TABLE OF zsord_vendor_RAP,
lt_data_upd TYPE STANDARD TABLE OF zsord_vendor_RAP.
*** Create
lt_data_cr = VALUE #( FOR row IN lcl_buffer=>mt_buffer_ord WHERE ( flag = 'C' ) ( row-data ) ).
IF lt_data_cr IS NOT INITIAL.
INSERT zsord_vendor_RAP FROM TABLE @lt_data_cr.

ENDIF.
*** Delete
lt_data_del = VALUE #( FOR row IN lcl_buffer=>mt_buffer_ord WHERE ( flag = 'D' ) ( row-data ) ).
IF lt_data_del IS NOT INITIAL.
DELETE zsord_vendor_RAP FROM TABLE @lt_data_del.
ENDIF.
*** Update
lt_data_upd = VALUE #( FOR row IN lcl_buffer=>mt_buffer_ord WHERE ( flag = 'U' ) ( row-data ) ).
IF lt_data_upd IS NOT INITIAL.
UPDATE zsord_vendor_RAP FROM TABLE @lt_data_upd.
ENDIF.
ENDMETHOD.
ENDCLASS.
