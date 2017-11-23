USE HorasExtSup
GO

-- ##SUMMARY Consulta información registrada en biométrico
-- ##AUTHOR  08/Sep/2017 Adriana Martinez
-- ##REMARKS 

--DROP PROCEDURE spAprobacionesRecuperar

CREATE PROCEDURE spAprobacionesRecuperar
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

	--Se verifica si el usuario es aprobador de departamento (Supervisor)
	IF EXISTS(SELECT 1 FROM BIOMETRICO.ONLYCONTROL.dbo.DPTO WHERE DEP_EM = @CodEmp)
	BEGIN
		--Se obtienen los empleados que pertenecen al departamento que aprueba
		SELECT	NOM.NOMINA_ID
				,NOM.NOMINA_NOM AS 'NOMBRE'
				,NOM.NOMINA_APE AS 'APELLIDO'
				,RIGHT('00'+CONVERT(VARCHAR,APR.TotalHoras50),2) + ':' + RIGHT('00'+CONVERT(VARCHAR,APR.TotalMinutos50),2) AS 'SUPLEMENTARIAS'
				,RIGHT('00'+CONVERT(VARCHAR,APR.TotalHoras100),2) + ':' + RIGHT('00'+CONVERT(VARCHAR,APR.TotalMinutos100),2) AS 'EXTRAORDINARIAS'
				,APR.UsuarioSuper
				,APR.FechaSuper
				,APR.UsuarioJefe
				,APR.FechaJefe
				,CONVERT(BIT,1) AS 'SUPERVISOR'
		FROM	BIOMETRICO.ONLYCONTROL.dbo.NOMINA NOM
		INNER	JOIN BIOMETRICO.ONLYCONTROL.dbo.DPTO DPT
		ON		NOM.NOMINA_DEP = DPT.DEP_ID
		INNER	JOIN HorasExtSup.dbo.tbAprobaciones APR
		ON		APR.CodigoEmp = NOM.NOMINA_ID
		INNER	JOIN #tbPeriodo PER
		ON		PER.anio = APR.Anio
		AND		PER.periodo = APR.PeriodoId
		WHERE	DEP_EM = @CodEmp
		--AND		APR.UsuarioSuper IS NULL
		ORDER	BY NOM.NOMINA_ID
	END

	--Se verifica si el usuario es aprobador de area (Jefe)
	IF EXISTS(SELECT 1 FROM BIOMETRICO.ONLYCONTROL.dbo.AREA WHERE AREA_EM = @CodEmp)
	BEGIN
		--Se obtienen los empleados del area que aprueba
		SELECT	NOM.NOMINA_ID
				,NOM.NOMINA_NOM AS 'NOMBRE'
				,NOM.NOMINA_APE AS 'APELLIDO'
				,RIGHT('00'+CONVERT(VARCHAR,APR.TotalHoras50),2) + ':' + RIGHT('00'+CONVERT(VARCHAR,APR.TotalMinutos50),2) AS 'SUPLEMENTARIAS'
				,RIGHT('00'+CONVERT(VARCHAR,APR.TotalHoras100),2) + ':' + RIGHT('00'+CONVERT(VARCHAR,APR.TotalMinutos100),2) AS 'EXTRAORDINARIAS'
				,APR.UsuarioSuper
				,APR.FechaSuper
				,APR.UsuarioJefe
				,APR.FechaJefe
				,CONVERT(BIT,0) AS 'SUPERVISOR'
		FROM	BIOMETRICO.ONLYCONTROL.dbo.NOMINA NOM
		INNER	JOIN BIOMETRICO.ONLYCONTROL.dbo.AREA ARE
		ON		NOM.NOMINA_AREA = ARE.AREA_ID
		INNER	JOIN HorasExtSup.dbo.tbAprobaciones APR
		ON		APR.CodigoEmp = NOM.NOMINA_ID
		INNER	JOIN #tbPeriodo PER
		ON		PER.anio = APR.Anio
		AND		PER.periodo = APR.PeriodoId
		WHERE	AREA_EM = @CodEmp
		--AND		APR.UsuarioJefe IS NULL
		ORDER	BY NOM.NOMINA_ID
	END

	----DATOS DEL EMPLEADO
	--SELECT	  @UsuarioId AS 'CodigoEmp'
	--		, PER.anio AS 'Anio'
	--		, PER.periodo AS 'Periodo'
	--		, PER.FechaInicial AS 'FechaInicial'
	--		, PER.FechaFinal AS 'FechaFinal'
	--FROM	#tbPeriodo	AS PER 

	DROP TABLE #tbPeriodo 
END
