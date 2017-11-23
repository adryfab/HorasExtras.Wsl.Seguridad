USE HorasExtSup
GO

-- ##SUMMARY Consulta información basica del empleado
-- ##AUTHOR  14/Sep/2017 Adriana Martinez
-- ##REMARKS 

--DROP PROCEDURE spDatosEmpleadoRecuperar

CREATE PROCEDURE spDatosEmpleadoRecuperar
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

	--DATOS DEL EMPLEADO
	SELECT	  @CodEmp AS 'CodigoEmp'
			, PER.anio AS 'Anio'
			, PER.periodo AS 'Periodo'
			, PER.FechaInicial AS 'FechaInicial'
			, PER.FechaFinal AS 'FechaFinal'
			, CASE WHEN ISNULL(APR.UsuarioSuper,'') <> '' OR ISNULL(APR.UsuarioJefe,'') <> '' THEN 1 ELSE 0 END AS 'Aprobado'
			, NOM.NOMINA_AREA1 AS 'Area'
			, NOM.NOMINA_AREA AS 'AreaId'
			, NOM.NOMINA_DEP1 AS 'Departamento'
			, NOM.NOMINA_DEP AS 'DepartamentoId'
			, NOM.NOMINA_CAL1 AS 'Cargo'
			, NOM.NOMINA_CAL AS 'CargoId'
	FROM	#tbPeriodo	AS PER 
	LEFT	JOIN HorasExtSup.dbo.tbAprobaciones APR
	ON		APR.CodigoEmp = @CodEmp 
	AND		APR.Anio = PER.anio
	AND		APR.PeriodoId = PER.periodo
	INNER	JOIN BIOMETRICO.ONLYCONTROL.dbo.NOMINA NOM
	ON		NOM.NOMINA_ID = @CodEmp

	DROP TABLE #tbPeriodo 
END
GO
