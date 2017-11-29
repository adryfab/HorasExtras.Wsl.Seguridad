USE HorasExtSup
GO

ALTER TABLE tbAprobaciones ADD HorasAtraso smallint DEFAULT(0) NULL
ALTER TABLE tbAprobaciones ADD MinutosAtraso smallint DEFAULT(0) NULL
GO
