USE HorasExtSup
GO

--DROP TABLE tbAtrasos

CREATE TABLE tbAtrasos
(
	 AtrasosId bigint PRIMARY KEY IDENTITY(1,1) NOT NULL
	,UsuarioId varchar(50) NOT NULL
	,CodigoEmp int NOT NULL
	,Anio int NOT NULL
	,PeriodoId int NOT NULL
	,Fecha date NULL
	,Ingreso datetime NULL
	,Tiempo datetime NULL
	,CodNovedad varchar(2) NULL
	,DetNovedad varchar (30)
	,Descripcion varchar(MAX) NULL
	,Activo bit DEFAULT(1) NOT NULL
	,Biometrico bit DEFAULT(1) NOT NULL
)
GO
