USE HorasExtSup
GO

--DROP TABLE tbAprobaciones

CREATE TABLE tbAprobaciones
(
	--Aprobaciones int PRIMARY KEY IDENTITY(1,1) NOT NULL,
	CodigoEmp int NOT NULL,
	Anio int NOT NULL,
	PeriodoId int NOT NULL,
	TotalHoras50 smallint NULL,
	TotalMinutos50 smallint NULL,
	TotalHoras100 smallint NULL,
	TotalMinutos100 smallint NULL,
	FechaRegistro datetime NULL,
	UsuarioRegistro varchar(50) NULL,
	UsuarioSuper varchar(50) NULL,
	FechaSuper datetime NULL,
	UsuarioJefe varchar(50) NULL,
	FechaJefe datetime NULL,
)
GO
