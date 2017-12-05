USE HorasExtSup
GO

-- ##SUMMARY Consulta la informacion de todas las aprobaciones con horas para extracion
-- ##AUTHOR  03/Oct/2017 Adriana Martinez
-- ##REMARKS 
-- ##HISTORY 01/Dic/2017 Adriana Martinez
-- ##HISTORY Cambiando columnas de totales por las de atrasos

ALTER PROCEDURE spProcesarTotales
AS
BEGIN
	--Obtiene el ultimo periodo 
	SELECT	 TOP 1 
			 anio AS 'anio'
			,periodo AS 'periodo'
			,fecha_inicial AS 'FechaInicial'
			,fecha_final AS 'FechaFinal'
	INTO 	#tbPeriodo 
	FROM BIOMETRICO.TCONTROL.dbo.TBL_PERIODO 
	ORDER BY anio DESC, periodo DESC

	--50%
	SELECT 
			 NOM.NOMINA_COD AS 'Cedula'
			,'0200' AS 'Cod'
			,CONVERT(VARCHAR,APR.Horas50Atraso) + '.' + RIGHT('00'+CONVERT(VARCHAR,APR.Minutos50Atraso),2) AS '50'
	FROM	HorasExtSup.dbo.tbAprobaciones APR
	INNER	JOIN #tbPeriodo PER
	ON		PER.anio = APR.Anio
	AND		PER.periodo = APR.PeriodoId
	INNER	JOIN BIOMETRICO.ONLYCONTROL.dbo.NOMINA NOM
	ON		NOM.NOMINA_ID = APR.CodigoEmp
	WHERE	(ISNULL(APR.Minutos50Atraso,0) > 0 OR ISNULL(APR.Horas50Atraso,0) > 0)

	--100%
	SELECT 
			 NOM.NOMINA_COD AS 'Cedula'
			,'0201' AS 'Cod'
			,CONVERT(VARCHAR,APR.Horas100Atraso) + '.' + RIGHT('00'+CONVERT(VARCHAR,APR.Minutos100Atraso),2) AS '100'
	FROM	HorasExtSup.dbo.tbAprobaciones APR
	INNER	JOIN #tbPeriodo PER
	ON		PER.anio = APR.Anio
	AND		PER.periodo = APR.PeriodoId
	INNER	JOIN BIOMETRICO.ONLYCONTROL.dbo.NOMINA NOM
	ON		NOM.NOMINA_ID = APR.CodigoEmp
	WHERE	(ISNULL(APR.Minutos100Atraso,0) > 0 OR ISNULL(APR.Horas100Atraso,0) > 0)

	DROP TABLE #tbPeriodo
END
GO
