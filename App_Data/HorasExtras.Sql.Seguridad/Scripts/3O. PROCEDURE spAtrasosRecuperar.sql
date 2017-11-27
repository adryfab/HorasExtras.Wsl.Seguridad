USE HorasExtSup
GO

-- ##SUMMARY Recupera los atrasos del usuario
-- ##AUTHOR  24/Nov/2017 Adriana Martinez
-- ##REMARKS 

--DROP PROCEDURE spAtrasosRecuperar

CREATE PROCEDURE spAtrasosRecuperar
	 @UsuarioId VARCHAR(50) 
AS
BEGIN
	--Obtiene el codigo del empleado
	DECLARE @CodEmp int
	SELECT	@CodEmp	 = @UsuarioId

	--Obtiene el ultimo periodo 
	SELECT	 TOP 1 
			 anio AS 'anio'
			,periodo AS 'periodo'
			,fecha_inicial AS 'FechaInicial'
			,fecha_final AS 'FechaFinal'
	INTO 	#tbPeriodo 
	FROM BIOMETRICO.TCONTROL.dbo.TBL_PERIODO 
	ORDER BY anio DESC, periodo DESC

	--Obtiene la información del biometrico
	SELECT 
			  TBL.EMP_ID AS 'CodigoEmp'
			, SUBSTRING(dbo.fnObtenerNombreDia(TBL.Fecha_Ingreso), 1, 3) AS 'Dia'
			, CONVERT(VARCHAR, TBL.Fecha_Ingreso, 111) AS 'Fecha'
			, TBL.Fecha_Ingreso +' '+ CONVERT(VARCHAR(5), TBL.Hora_Ingreso , 114) AS 'Ingreso'
			, TBL.Fecha_Ingreso +' '+ RIGHT( convert(char(8), dateadd(second, TBL.min_AT, ''), 114) ,5) AS 'Tiempo'
			, TBL.Novedad_Entrada COLLATE DATABASE_DEFAULT AS 'CodNov'
			, CAT.CD_NOM COLLATE DATABASE_DEFAULT AS 'Tipo'
			, ISNULL(ATR.Descripcion,'') AS 'Justificativo'
			, ISNULL(ATR.AtrasosId,0) AS 'AtrasosId'
			, PER.anio AS 'Anio'
			, PER.periodo AS 'Periodo'
			, ISNULL(ATR.Activo,1) AS 'Activo'
			, 1 AS 'Biometrico'
			, 0 AS 'Aprobado'
	FROM	BIOMETRICO.TCONTROL.dbo.TBL_ASISTENCIA TBL
	INNER	JOIN #tbPeriodo PER
	ON		TBL.Fecha_Ingreso >= PER.FechaInicial
	INNER	JOIN BIOMETRICO.TCONTROL.dbo.TBL_CAT_DETALLE CAT
	ON		TBL.Novedad_Entrada = CAT.CD_ID
	LEFT	JOIN tbAtrasos AS ATR
	ON		ATR.CodigoEmp = TBL.EMP_ID
	AND		ATR.Fecha = TBL.Fecha_Ingreso
	AND		CONVERT(VARCHAR(5),ISNULL(TBL.Hora_Ingreso,0), 114) = CONVERT(VARCHAR(5),ISNULL(ATR.Ingreso,0), 114)
	WHERE	TBL.Novedad_Entrada NOT IN ('OK', 'EG', 'PE') --'FI', 
	AND		TBL.EMP_ID = @CodEmp
	--AND		TBL.min_AT > 0
	AND NOT EXISTS (SELECT 1 FROM tbAtrasos EX WHERE EX.CodigoEmp = TBL.EMP_ID AND EX.Fecha = TBL.Fecha_Ingreso)

	UNION 

	--Obtiene la información ingresada por el usuario
	SELECT
			  ATR.CodigoEmp AS 'CodigoEmp'
			, SUBSTRING(dbo.fnObtenerNombreDia(ATR.Fecha), 1, 3) AS 'Dia'
			, ATR.Fecha AS 'Fecha'
			, CASE WHEN CONVERT(VARCHAR(5),ISNULL(ATR.Ingreso,0), 114) = '00:00' THEN NULL ELSE ATR.Ingreso END AS 'Ingreso'
			, ATR.Tiempo AS 'Tiempo'
			, ATR.CodNovedad COLLATE DATABASE_DEFAULT AS 'CodNov'
			, ATR.DetNovedad COLLATE DATABASE_DEFAULT AS 'Tipo'
			, ATR.Descripcion AS 'Justificativo'
			, ATR.AtrasosId AS 'AtrasosId'
			, ATR.Anio AS 'Anio'
			, ATR.PeriodoId AS 'Periodo'
			, ISNULL(ATR.Activo,1) AS 'Activo'
			, ATR.Biometrico AS 'Biometrico'
			, ATR.Aprobado AS 'Aprobado'
	FROM	HorasExtSup.dbo.tbAtrasos ATR
	INNER	JOIN #tbPeriodo	AS PER 
	ON		PER.anio = ATR.Anio
	AND		PER.periodo = ATR.PeriodoId
	WHERE	ATR.Activo = 1
	AND		ATR.CodigoEmp = @CodEmp 
	ORDER	BY 3, 4

	DROP TABLE #tbPeriodo

END
