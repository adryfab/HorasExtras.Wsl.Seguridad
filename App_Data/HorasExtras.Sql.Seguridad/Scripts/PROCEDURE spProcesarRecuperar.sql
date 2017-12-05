USE HorasExtSup
GO

-- ##SUMMARY Consulta la informacion de todos los usuarios del biometrico
-- ##AUTHOR  02/Oct/2017 Adriana Martinez
-- ##REMARKS 

--DROP PROCEDURE spProcesarRecuperar

CREATE PROCEDURE spProcesarRecuperar
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

	SELECT	  DISTINCT
			  TBL.EMP_ID AS 'CodigoEmp'
			, NOM.NOMINA_COD AS 'Cedula'
			, NOM.NOMINA_NOM AS 'Nombre'
			, NOM.NOMINA_APE AS 'Apellido'
			, NOM.NOMINA_AREA1 AS 'Area'
			, NOM.NOMINA_AREA AS 'AreaId'
			, NOM.NOMINA_DEP1 AS 'Departamento'
			, NOM.NOMINA_DEP AS 'DepartamentoId'
			, NOM.NOMINA_CAL1 AS 'Cargo'
			, NOM.NOMINA_CAL AS 'CargoId'
			, CASE WHEN ISNULL(UsuarioSuper,'') <> '' OR ISNULL(UsuarioJefe,'') <> '' THEN 1 ELSE 0 END AS 'Aprobado'
	FROM	BIOMETRICO.TCONTROL.dbo.TBL_ASISTENCIA TBL
	INNER	JOIN #tbPeriodo	AS PER 
	ON		TBL.Fecha_Ingreso between PER.FechaInicial and PER.FechaFinal
	LEFT	JOIN HorasExtSup.dbo.tbAprobaciones APR
	ON		APR.CodigoEmp = TBL.EMP_ID
	INNER	JOIN BIOMETRICO.ONLYCONTROL.dbo.NOMINA NOM
	ON		NOM.NOMINA_ID = TBL.EMP_ID
	ORDER	BY NOM.NOMINA_AREA, NOM.NOMINA_DEP, TBL.EMP_ID

	DROP TABLE #tbPeriodo
END
GO
