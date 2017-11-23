USE master
GO

EXEC master.dbo.sp_addlinkedserver @server = N'BIOMETRICO', @srvproduct=N'SQL', @provider=N'SQLNCLI', @datasrc=N'SGYEDB13'
 /* For security reasons the linked server remote logins password is changed with ######## */
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname=N'BIOMETRICO',@useself=N'False',@locallogin=NULL,@rmtuser=N'usrBio',@rmtpassword='########'

GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'collation compatible', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'data access', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'dist', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'pub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'rpc', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'rpc out', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'sub', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'connect timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'collation name', @optvalue=null
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'lazy schema validation', @optvalue=N'false'
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'query timeout', @optvalue=N'0'
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'use remote collation', @optvalue=N'true'
GO

EXEC master.dbo.sp_serveroption @server=N'BIOMETRICO', @optname=N'remote proc transaction promotion', @optvalue=N'false'
GO
