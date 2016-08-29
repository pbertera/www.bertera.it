Title: vtiger CRM: Howto add products commissions in invoice 
Date: 2012-09-27 13:27
Author: admin
Tags: crm, php, vtiger
Slug: vtiger-crm-howto-add-products-commissions-in-invoice
Status: published

During last days I played with [vtiger](https://www.vtiger.com): a very
customizable and feature rich PHP/MySQL CRM. Sincerely this task has
revived my intimate [hate](http://www.google.com/search?q=php+sucks) for
PHP programming language.

This is the idea: add a function hook in vtiger workflow every time that
an invoice is created or edited. This function must take care to update
invoice commission based on products commissions rates.

**First step: Create the hook function:**  
Create a new file  under "include" folder: `vim include/CommissionHandler.php`

Following the content of this file:

```
<?php   
function updateCommission($entity){   
  global $log, $adb;   
  $entityArray = get_object_vars($entity);       
  $invoice_id = vtws_getIdComponents($entity----->getId());
  $invoice_id = $invoice_id[1];
  $log->debug("Entering into function updateRebate(".$invoice_id.").");
 
  $products = $adb->pquery("SELECT productid, quantity from vtiger_inventoryproductrel WHERE id=?", array($invoice_id));
  $numrows = $adb->num_rows($products);
  $rebate = 0;
  for($index = 0;$index query_result($products,$index,'productid');
    $quantity = $adb->query_result($products,$index,'quantity');
 
    $commission_info = $adb->pquery("SELECT unit_price, commissionrate from vtiger_products WHERE productid=?", array($productid));
 
    $commission_rate = $adb->query_result($commission_info, 0, 'commissionrate');
    $price = $adb->query_result($commission_info, 0, 'unit_price');
 
    $rebate = $rebate + ($quantity * ($price * $commission_rate / 100));
  }
  $adb->pquery("UPDATE vtiger_invoice SET salescommission=$rebate WHERE invoiceid=?", array($invoice_id));
}
?>
```

Second Step: register the hook  

Create a new php file: `vim reg.php`

Following the content of reg.php:

```
<?php 
require_once 'include/utils/utils.php'; 
require 'modules/com_vtiger_workflow/VTEntityMethodManager.inc'; 
$emm = new VTEntityMethodManager($adb); 
#addEntityMethod("Module", "LABEL", "FILENAME", "FUNCTION_NAME"); 
$emm->addEntityMethod("Invoice", "Update Commission", "include/CommissionHandler.php", "updateCommission");
?>
```

Execute the registration script:

via CLI: `php -f reg.php` or via Web: `wget http://your.vtiger.url/vtiger-pat/reg.php -O > /dev/null`

**Third Step: Associate the function hook to an invoice workflow:**

- Under the vtiger admin panel, select **"Workflow"** and then **"New Workflow"**.  
- Select **"For Module"**, select **"Invocie"** Module  
- Fill the description field with a descriptive name eg. "Update Invoice Commission"  
- Select **"Every time the record is saved."** radio button  
- Click Save button  
- Leave conditions empty  
- Click on **"New Task"** button  
- Select **"Invoke custom function"**  
- Assign a Task title and select **"Update Commission"** method  
- Click **"Save"**

**Fourth Step: Play with invoice and products commissions.**
