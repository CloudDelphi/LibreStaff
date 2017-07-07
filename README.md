# LibreStaff
LibreStaff is a open source software for the management of the personnel of an enterprise.<br />

Features
-----------------------
Programming Language: <a href="http://www.freepascal.org/">Free Pascal</a><br />
Systems: Win32/Linux
Compiler: <a href="http://www.lazarus-ide.org/">Lazarus</a><br />
Database engine: <a href="https://www.sqlite.org/">SQLite</a> and MySQL.<br />
Languages: English, Spanish & Portuguese.  
License: GPLv3

Goals
----------
<ul>
	<li>Create a database of employees: personal data, professional data, holidays, time of sicks...</li>
	<li>Searchs & queries.</li>
	<li>Generate reports.</li>
	<li>User system access by password and permissions.</li>
	<li>Update engine via the Web or local.</li>
	<li>Website engine.</li>
 </ul>
<br/>

How to Compile
--------------
1) Download & install Lazarus. ¡Version <strong>1.6.4</strong> or above! Get it here: <a href="http://www.lazarus-ide.org">Lazarus Home</a>.<br />
2) Install manually the <a href="http://wiki.freepascal.org/RichMemo">RichMemo</a> component into Lazarus. (it's in the "richmemo" folder). Also with the  	"dcpcrypt-2.0.4.1" package.<br />
3) Install the "LazReport" component into Lazarus included with the source code. (it's in the "lazreport" folder). The first time you compile, automatically Lazarus request this installation.<br />
4) Install the "uniqueinstance" component included.<br />
5) Delete data.db file if exists.<br />
6) Open the project (librestaff.lpi).<br />
7) Go to "Project" -> "Options" and select the build mode: Win32 or Linux.
8) Go to "Menu" -> Compile.<br />

Superuser
---------
The admin account created by default for access control (if enabled) is the following:<br />
user: SUPERUSER<br />
password: 1234

How to Create Install Package
--------------------------------------
*Windows*<br />
Install Inno Setup (it's a free installer for Windows programs available in the Web) and then open "innosetup_installscript.iss" file.
<br /><br />
*Linux*<br />
Execute in terminal the "create_deb_package_script" script.<br />

