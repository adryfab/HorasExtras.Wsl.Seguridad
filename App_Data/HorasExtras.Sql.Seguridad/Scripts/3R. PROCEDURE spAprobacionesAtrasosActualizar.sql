USE HorasExtSup
GO

-- ##SUMMARY Realiza la sumatoria y actualizacion de los atrasos en tabla de Aprobaciones
-- ##SUMMARY Solo se suman los atrasos cuando no estan aprobados
-- ##AUTHOR  29/Nov/2017 Adriana Martinez
-- ##REMARKS 

-- DROP PROCEDURE spAprobacionesAtrasosActualizar

CREATE PROCEDURE spAprobacionesAtrasosActualizar
	@UsuarioId varchar(50)
AS
BEGIN TRY
	BEGIN TRAN

	--Obtiene el codigo del empleado
	DECLARE @CodEmp int
	SELECT	@CodEmp	 = @UsuarioId

	DECLARE  @TotalAtraso time(0)
			,@HorasAtraso smallint
			,@MinutosAtraso smallint

	--Obtiene el ultimo periodo 
	SELECT	 TOP 1 
			 anio AS 'anio'
			,periodo AS 'periodo'
			,fecha_inicial AS 'FechaInicial'
			,fecha_final AS 'FechaFinal'
	INTO 	#tbPeriodo 
	FROM BIOMETRICO.TCONTROL.dbo.TBL_PERIODO 
	ORDER BY anio DESC, periodo DESC

	--Se suman los atrasos
	SELECT @TotalAtraso = CONVERT(varchar(8), DATEADD(SECOND, SUM(DATEDIFF(SECOND, '', CONVERT(time, tiempo))), 0),  108)
	FROM
	(
		--Obtiene la información del biometrico
		SELECT 
				TBL.Fecha_Ingreso +' '+ RIGHT( convert(char(8), dateadd(second, TBL.min_AT, ''), 114) ,5) AS 'Tiempo'
		FROM	BIOMETRICO.TCONTROL.dbo.TBL_ASISTENCIA TBL
		INNER	JOIN #tbPeriodo PER
		ON		TBL.Fecha_Ingreso >= PER.FechaInicial
		INNER	JOIN BIOMETRICO.TCONTROL.dbo.TBL_CAT_DETALLE CAT
		ON		TBL.Novedad_Entrada = CAT.CD_ID
		LEFT	JOIN tbAtrasos AS ATR
		ON		ATR.CodigoEmp = TBL.EMP_ID
		AND		ATR.Fecha = TBL.Fecha_Ingreso
		AND		CONVERT(VARCHAR(5),ISNULL(TBL.Hora_Ingreso,0), 114) = CONVERT(VARCHAR(5),ISNULL(ATR.Ingreso,0), 114)
		WHERE	TBL.Novedad_Entrada NOT IN ('OK', 'EG', 'PE')
		AND		TBL.EMP_ID = @CodEmp
		AND NOT EXISTS (SELECT 1 FROM tbAtrasos EX WHERE EX.CodigoEmp = TBL.EMP_ID AND EX.Fecha = TBL.Fecha_Ingreso)
		UNION 
		--Obtiene la información ingresada por el usuario
		SELECT
				ATR.Tiempo AS 'Tiempo'
		FROM	HorasExtSup.dbo.tbAtrasos ATR
		INNER	JOIN #tbPeriodo	AS PER 
		ON		PER.anio = ATR.Anio
		AND		PER.periodo = ATR.PeriodoId
		WHERE	ATR.Activo = 1
		AND		ATR.CodigoEmp = @CodEmp 
		AND		ATR.Aprobado = 0
	) AS X
	
	--Se divide en horas y minutos
	SELECT	 @HorasAtraso = DATEPART(HOUR,@TotalAtraso) 
			,@MinutosAtraso = DATEPART(MINUTE,@TotalAtraso)

	--Si existe se actualiza
	IF EXISTS(SELECT 1 FROM tbAprobaciones APR INNER JOIN #tbPeriodo PER ON PER.anio = APR.Anio AND PER.periodo = APR.PeriodoId AND APR.CodigoEmp = @CodEmp)
	BEGIN 
		UPDATE tbAprobaciones
		SET  HorasAtraso = @HorasAtraso
			,MinutosAtraso = @MinutosAtraso
		FROM tbAprobaciones APR 
		INNER JOIN #tbPeriodo PER 
		ON PER.anio = APR.Anio 
		AND PER.periodo = APR.PeriodoId 
		AND APR.CodigoEmp = @CodEmp
	END
	ELSE --Si no existe se inserta
	BEGIN
		INSERT INTO tbAprobaciones
		(
			 CodigoEmp 
			,Anio 
			,PeriodoId 
			,TotalHoras50 
			,TotalMinutos50 
			,TotalHoras100 
			,TotalMinutos100 
			,FechaRegistro 
			,UsuarioRegistro 
			,UsuarioSuper
			,FechaSuper
			,UsuarioJefe
			,Fechajefe
			,HorasAtraso
			,MinutosAtraso
		)
		SELECT	 @CodEmp		AS 'CodigoEmp'
				,PER.anio		AS 'Anio'
				,PER.periodo	AS 'PeriodoId'
				,NULL			AS 'TotalHoras50'
				,NULL			AS 'TotalMinutos50'
				,NULL			AS 'TotalHoras100'
				,NULL			AS 'TotalMinutos100'
				,GETDATE()		AS 'FechaRegistro'
				,NULL			AS 'UsuarioRegistro'
				,NULL			AS 'UsuarioSuper'
				,NULL			AS 'FechaSuper'
				,NULL			AS 'UsuarioJefe'
				,NULL			AS 'Fechajefe'
				,@HorasAtraso	AS 'HorasAtraso'
				,@MinutosAtraso AS 'MinutosAtraso'
		FROM #tbPeriodo PER
	END

	--Se borra la tabla temporal
	DROP TABLE #tbPeriodo
	
	--Se procesa la transacción.
    IF @@TRANCOUNT > 0 
	BEGIN
		COMMIT  TRAN 
	END
END TRY
BEGIN CATCH
	--En caso de error se realiza un rollback de la transaccion
	IF @@TRANCOUNT > 0 
       ROLLBACK TRAN        
END CATCH
GO
