USE HorasExtSup
GO

ALTER TABLE tbAprobaciones ADD HorasAtraso smallint DEFAULT(0) NULL
ALTER TABLE tbAprobaciones ADD MinutosAtraso smallint DEFAULT(0) NULL
ALTER TABLE tbAprobaciones ADD Horas50Atraso smallint DEFAULT(0) NULL
ALTER TABLE tbAprobaciones ADD Minutos50Atraso smallint DEFAULT(0) NULL
ALTER TABLE tbAprobaciones ADD Horas100Atraso smallint DEFAULT(0) NULL
ALTER TABLE tbAprobaciones ADD Minutos100Atraso smallint DEFAULT(0) NULL
GO
