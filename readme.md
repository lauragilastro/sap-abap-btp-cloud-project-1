# SAP ABAP BTP Cloud Project 1
In this project I'm going to develop an ABAP Cloud module built to handle work orders for a service company. The module is focused on the backend side, performance optimization and validations, excluding the UI implementation.

## Tools
- Eclipse.
- BTP trial.
- My own notes from the Logali master's program manual.
- Claude Pro.

## Step 1: Domains
5 domains needed for 5 data elements:
- ZD_CUSTOMER_ID_LGO
- ZD_PRIORITY_LGO
- ZD_STATUS_LGO
- ZD_TECHNICIAN_ID_LGO
- ZD_WORK_ORDER_ID_LGO

## Step 2: Data Elements
I created 5 data elements:
- ZDE_CUSTOMER_ID_LGO
- ZDE_PRIORITY_LGO
- ZDE_STATUS_LGO
- ZDE_TECHNICIAN_ID_LGO
- ZDE_WORK_ORDER_ID_LGO

## Step 3: Transparent Tables
Also I created the 4 transparent tables:
- ZTCUSTOMER_LGO
- ZTTECHNICIAN_LGO
- ZTWORK_HIST_LGO
- ZTWORK_ORDER_LGO

Two of them need foreign keys because customer_id and technician_id in the work order can only point to a customer or technician that exists in the corresponding table. In other words: only for registered IDs.

## Step 4: Table Type
Table type needed for the future methods.

## Step 5: Authorization Object
I created an authorization object with the field ACTVT and its 4 allowed activities: 01 Create, 02 Change, 03 Display, 06 Delete.
This allows control over the operations a user can perform on work orders, depending on the role assigned to them.

## Step 6: Validation Class
We need a validation class to make sure everything is okay before CRUD class works.
If validations are false or make errors, I created an exception class (ZCX_VALIDATION_LGO) with my own message class (ZCX_MSG_LGO) with personalized messages:
001 Customer does not exist.
002 Technician does not exist.
003 Priority not valid.
004 Status not valid.

### 6.1. validate_create_order:
We need a validation method to make sure customers and technicians exist. The method used SELECT IF/ELSE to confirm it.
Also validates priority and status calling validate_status_and_priority.

### 6.2 validate_update_order:
We need a validation method to make sure a work order can be updated only if it exists in the DB table and its status = PE.
The method used SELECT first to prove the row exists (otherwise = work order not found) and IF/ELSEIF to rule out non-pending (non-PE) rows. No ELSE needed because it can only fail in two ways.

### 6.3 validate_delete_order:
If the customer wants to delete an order, the order can only be deleted under these conditions: work order exists and it's still PE and it is not updated in the history, otherwise if it's updated it means that it was processed by the technician.
IF was used to prove again that work order exists or if it's non-pending (non-PE) (2 conditions) = work order not found.
And if the system detects a non-empty history table, system shows message: work order is already processed.

### 6.4. validate_status_and_priority:
Also, we need a validation method for priority (A/B anyways) and status (only PE at the beginning).

## Step 7: CRUD class:
CRUD class is the program's actual motor. This class is divided into two methods:

### 7.1 method 1: create_work_order:
1. Before the work order's creation, the method uses the other class (previously created in step 6) zcl_work_order_validator_lgo to validate if everything we need to proceed exists, so if rv_valid = abap_true we can continue.
2. The method always catches the same text-error messages as the validator class shows in case of any error.
3. After the validation checks everything OK, the method inserts a new work order row in the work order table, forcing status PE.

*Technician makes the work*

### 7.2 method 2: update_work_order:
1. The method validates again same way as previous method to make sure everything is OK before proceeding.
2. The method updates work order table changing status from PE to CO.
3. Finally, the method inserts the updated work order in the history, filling the other fields: history_id value is generated taking the last history_id + 1 and for the date, the system captures the current system date using the standard system class: cl_abap_context_info=>get_system_date( ).
   
Note: I prefer to use VALUE #( instead create a variable, fill line by line and at last make the INSERT. It's the shortest and cleanest way for me.

### 7.3 method 3: delete_work_order:
The method calls validate_delete_order inside a TRY/CATCH block. If the validator raises an exception (order doesn't exist, isn't in PE status, or already has history), the error message is caught and returned. Otherwise, the row is deleted.

### 7.4 method 4: read_work_order:
If someone wants to read the work order's table, they only need to enter the work order ID and system shows all table's fields (FIELDS *).
At the beginning I considered making 4 read methods (one per table), but I decided not to, because the customer and technician tables contain personal data that shouldn't be exposed.

### 7.5 method 5: read_history
I decided to add this on my own initiative, to check lastest updates. I think that this is necessary.
For this method I needed to create a table type, because RETURNING only brings one row, to bring more rows it needs a dictionary table type, so this is the result in DEFINITION: RETURNING VALUE(rt_history) TYPE ztt_work_hist_lgo.
