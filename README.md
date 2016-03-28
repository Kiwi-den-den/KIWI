What are Kiwi and Cassava?
Kiwi is a STATA ADO file or a package that creates a GUI (Graphical User Interface) within STATA to make exploring the BLS Consumer Expenditure Micro-Data a bit less difficult. It is intended for getting a basic idea of what the data are saying. It has limited options, and places the user in a sandbox. Advance user or those wanting more than basic means should use Cassava.
  Cassava is a script that is written in STATA language that makes collating and formatting BLS Consumer Expenditure Micro-Data. It is a template that can be used by advance STATA users to turn the CE survey data into useable data. The user has full control over which variables to create or format, however, it does require a healthy knowledge of STATA commands and language. 	
  
What do I need to know about the data?	
Please check out the BLS's webpage on the CE Survey microdata. You will not be able to use the scripts if you are not famliar with how to use the data.	
Main Data Page	
http://www.bls.gov/cex/pumdhome.htm	
	
Surevy Forms Page	
http://www.bls.gov/cex/csxsurveyforms.htm#interview	
	
 Guide to Data	
http://www.bls.gov/cex/pumd_novice_guide.pdf	

How do I use Kiwi or Cassava? 	
First download the data	
1)	The data can be downloaded directly from the BLS CE Survey website http://www.bls.gov/cex/pumdhome.htm or,	
2)	For the user’s convenience we have included a link to the formatted version of the data from 1996 to 2014, only the family	 interview survey is included.  https://www.dropbox.com/s/7p2u4en2c83fnxu/CEX_data_files1.rar?dl=0	
	
3)	Save the data with the following directory location	
a.	C:\\CEX\		
b.	If you choose any other location you must modify the scripts to reflect new location		
c. the individual yearly files should follow this format 		
		C:\\CEX\"Year"\"Year" for example data files for 1996 should be located at C:\CEX\1992\1992\		
			
To use kiwi		
1) Download the KIWI folder		
2) Copy the contents of the “KIWI” file to your personal ado dir		
3) From the STATA Command window type “kiwi2”		
To use Cassava	
1) Open the do file with STATA’s do file editor	
2) Edit the file to reflect the user’s needs	
3) Run using STATA commands 	
