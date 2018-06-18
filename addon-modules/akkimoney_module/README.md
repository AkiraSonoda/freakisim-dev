# akkimoney_module

## Outline

This Module is a modified version of DTLNSLMoneyModule by by Fumi.Iseki.
This Module only works with the corresponding AkkiMoney Server.
This Module and the AkkiMoney Server currently is very insecure because of missing encryption etc.
and therefore only thought for internal "funny money" or roleplaying purposes.  

This module is tested on the latest ArribaSim


## Install

Clone this Repository into the addon-modules directory of your OpenSim / ArribaSim instalation.

Copy the provided RestSharp.dll ( in the lib subdirectory ) into the OpenSim / Arriba bin subdirectory

Build the OpenSim.exe from the OpenSim or ArribaSim Sources



## Setting

### Money Server

The AkkiMoney Server implementation needed for this Module to work within
can be found here:  

https://bitbucket.org/AkiraSonoda/akkimoney

Please read the Documentation in this Repository on how to Setup and run the
AkkiMoney Server.

### Region Server

 [Economy]
   SellEnabled = "true"
   CurrencyServer = "https://(MoneyServer's Name or IP):8009/"  
   EconomyModule  = AkkiMoneyModule

   ;; Money Unit fee to upload textures, animations etc
   ;; PriceUpload = 10

   ;; Money Unit fee to create groups
   ;; PriceGroupCreate = 100


 Attention!
  - Do not use this Module without a working installation of the AkkiMoney Server
  - Not use 127.0.0.1 or localhost for UserServer's address and CurrencyServer's address.
    This address is used for identification of user on Money Server.



## License.

 This software is licensed under

 GNU AFFERO GENERAL PUBLIC LICENSE Version 3, 19 November 2007
 https://www.gnu.org/licenses/agpl.html


## Attention.

 This is unofficial software.
 Please do not inquire to OpenSim development team about this software.


## Exemption from responsibility.

  This software is not guaranteed at all. The author doesn't assume the responsibility for the
  problem that occurs along with use, remodeling, and the re-distribution of this software at all.
  Please use everything by the self-responsibility.

## Address of thanks.

  This Money Module is based on the DTLNSLMoneyModule
  by Fumi.Iseki and NSL '11 5/7
  http://www.nsl.tuis.ac.jp

  Thank you very much!!
