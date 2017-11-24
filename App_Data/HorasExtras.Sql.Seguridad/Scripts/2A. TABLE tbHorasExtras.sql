USE HorasExtSup
GO

--DROP TABLE tbHorasExtras

CREATE TABLE tbHorasExtras
(
	HorasExtrasId bigint PRIMARY KEY IDENTITY(1,1) NOT NULL,
	UsuarioId varchar(50) NOT NULL,
	CodigoEmp int NOT NULL,
	Anio int NOT NULL,
	PeriodoId int NOT NULL,
	Fecha date NULL,
	HoraIngreso time(0) NULL,
	HoraSalida time(0) NULL,
	HoraLaborado time(0) NULL,
	HoraAtrasado time(0) NULL,
	HoraAnticipado time(0) NULL,
	Horas0 time(0) NULL,
	Horas50 time(0) NULL,
	Horas100 time(0) NULL,
	HorasPermiso time(0) NULL,
	HorasRecuperar time(0) NULL,
	Descripcion varchar(MAX) NULL,
	Activo bit DEFAULT(1) NOT NULL,
	Biometrico bit DEFAULT(1) NOT NULL
)
GO
