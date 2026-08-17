# SAP ABAP BTP Cloud Project 1
In this project I'm going to develop an ABAP Cloud module built to handle work orders for a service company. The module is focused on the backend side, performance optimization and validations, excluding the UI implementation.

## Tools
- Eclipse.
- BTP trial.
- My own notes from the master's program manual.
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
