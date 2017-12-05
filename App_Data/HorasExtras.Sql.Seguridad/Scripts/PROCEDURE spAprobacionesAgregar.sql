USE HorasExtSup
GO

-- ##SUMMARY Ingresa la informacion en la tabla tbAprobaciones
-- ##AUTHOR  29/Nov/2017 Adriana Martinez
-- ##REMARKS 

--DROP PROCEDURE spAprobacionesAgregar

CREATE PROCEDURE spAprobacionesAgregar
	 @UsuarioId		varchar(50) 
	,@InfoXml		xml
AS
BEGIN TRY
	BEGIN TRAN

	---*** CABECERA PARA APROBACIONES ***---
	DECLARE  @horas50 as smallint
			,@minutos50 as smallint
			,@horas100 as smallint
			,@minutos100 as smallint
			,@horasPermiso as smallint
			,@minutosPermiso as smallint
			,@horasRecuperar as smallint
			,@minutosRecuperar as smallint
			,@totalHoras50 as smallint
			,@totalMinutos50 as smallint
			,@totalHoras100 as smallint
			,@totalMinutos100 as smallint

	SELECT   @horas50			= (SUM(DATEPART(HOUR,Horas50))) + ((SUM(DATEPART(MINUTE,Horas50)))/60)
			,@minutos50			= (SUM(DATEPART(MINUTE,Horas50)))%60
			,@horas100			= (SUM(DATEPART(HOUR,horas100))) + ((SUM(DATEPART(MINUTE,horas100)))/60)
			,@minutos100		= (SUM(DATEPART(MINUTE,horas100)))%60
			,@horasPermiso		= (SUM(DATEPART(HOUR,HorasPermiso))) + ((SUM(DATEPART(MINUTE,HorasPermiso)))/60)
			,@minutosPermiso	= (SUM(DATEPART(MINUTE,HorasPermiso)))%60
			,@horasRecuperar	= (SUM(DATEPART(HOUR,HorasRecuperar))) + ((SUM(DATEPART(MINUTE,HorasRecuperar)))/60)
			,@minutosRecuperar	= (SUM(DATEPART(MINUTE,HorasRecuperar)))%60
	FROM tbHorasExtras HE
	INNER JOIN @InfoXml.nodes('/HOREXT') AS M(X) 
	ON HE.CodigoEmp = M.X.value('@CODEMP', 'int')
	AND HE.Anio = M.X.value('@ANIOPE', 'int')
	AND HE.PeriodoId = M.X.value('@PERIOD', 'int')
	WHERE HE.Activo = 1

	IF (@minutos50 >= @minutosPermiso)
	BEGIN
		select 
			    @totalHoras50 = horas_h50-horas_per 
			  , @totalMinutos50 = minutos_h50-minutos_per 
		from (
			SELECT ((SUM(DATEPART(HOUR, horas50 )) )+(SUM(DATEPART(MINUTE, horas50 )) )/60) as horas_h50,(SUM(DATEPART(MINUTE, horas50 )) )%60 as minutos_h50, 
			((SUM(DATEPART(HOUR, HorasPermiso )) )+(SUM(DATEPART(MINUTE, HorasPermiso )) )/60) as horas_per,(SUM(DATEPART(MINUTE, HorasPermiso )) )%60 as minutos_per
			FROM tbHorasExtras HE
			INNER JOIN @InfoXml.nodes('/HOREXT') AS M(X) 
			ON HE.CodigoEmp = M.X.value('@CODEMP', 'int')
			AND HE.Anio = M.X.value('@ANIOPE', 'int')
			AND HE.PeriodoId = M.X.value('@PERIOD', 'int')
			WHERE HE.Activo = 1
		) a
	END
	ELSE
	BEGIN
		select 
			   @totalHoras50 = horas_h50-horas_per-1 
			 , @totalMinutos50 = ((minutos_h50-(minutos_per+60))+60)*(-1)
		from (
			SELECT ((SUM(DATEPART(HOUR, horas50 )) )+(SUM(DATEPART(MINUTE, horas50 )) )/60) as horas_h50,(SUM(DATEPART(MINUTE, horas50 )) )%60 as minutos_h50, 
			((SUM(DATEPART(HOUR, HorasPermiso )) )+(SUM(DATEPART(MINUTE, HorasPermiso )) )/60) as horas_per,(SUM(DATEPART(MINUTE, HorasPermiso )) )%60 as minutos_per
			FROM tbHorasExtras HE
			INNER JOIN @InfoXml.nodes('/HOREXT') AS M(X) 
			ON HE.CodigoEmp = M.X.value('@CODEMP', 'int')
			AND HE.Anio = M.X.value('@ANIOPE', 'int')
			AND HE.PeriodoId = M.X.value('@PERIOD', 'int')
			WHERE HE.Activo = 1
		) a
	END

	IF (@minutos100 >= @minutosRecuperar)
	BEGIN
		select 
			    @totalHoras100 = horas_h100-horas_rec 
			  , @totalMinutos100 = minutos_h100-minutos_rec
		from (
			SELECT ((SUM(DATEPART(HOUR, Horas100 )) )+(SUM(DATEPART(MINUTE, Horas100 )) )/60) as horas_h100,(SUM(DATEPART(MINUTE, Horas100 )) )%60 as minutos_h100, 
			((SUM(DATEPART(HOUR, HorasRecuperar )) )+(SUM(DATEPART(MINUTE, HorasRecuperar )) )/60) as horas_rec,(SUM(DATEPART(MINUTE, HorasRecuperar )) )%60 as minutos_rec
			FROM tbHorasExtras HE
			INNER JOIN @InfoXml.nodes('/HOREXT') AS M(X) 
			ON HE.CodigoEmp = M.X.value('@CODEMP', 'int')
			AND HE.Anio = M.X.value('@ANIOPE', 'int')
			AND HE.PeriodoId = M.X.value('@PERIOD', 'int')
			WHERE HE.Activo = 1
		) a
	END
	ELSE
	BEGIN
		select 
			   @totalHoras100 = horas_h100-horas_rec-1 
			 , @totalMinutos100 = ((minutos_h100-(minutos_rec+60))+60)*(-1)
		from (
			SELECT ((SUM(DATEPART(HOUR, Horas100 )) )+(SUM(DATEPART(MINUTE, Horas100 )) )/60) as horas_h100,(SUM(DATEPART(MINUTE, Horas100 )) )%60 as minutos_h100, 
			((SUM(DATEPART(HOUR, HorasRecuperar )) )+(SUM(DATEPART(MINUTE, HorasRecuperar )) )/60) as horas_rec,(SUM(DATEPART(MINUTE, HorasRecuperar )) )%60 as minutos_rec
			FROM tbHorasExtras HE
			INNER JOIN @InfoXml.nodes('/HOREXT') AS M(X) 
			ON HE.CodigoEmp = M.X.value('@CODEMP', 'int')
			AND HE.Anio = M.X.value('@ANIOPE', 'int')
			AND HE.PeriodoId = M.X.value('@PERIOD', 'int')
			WHERE HE.Activo = 1
		) a
	END

	IF EXISTS(SELECT 1 FROM tbAprobaciones AS AP INNER JOIN @InfoXml.nodes('/HOREXT') AS M(X) ON AP.CodigoEmp = M.X.value('@CODEMP', 'int') 
		AND AP.Anio = M.X.value('@ANIOPE', 'int') AND AP.PeriodoId = M.X.value('@PERIOD', 'int'))
	BEGIN
		UPDATE tbAprobaciones 
		SET
			 TotalHoras50 = @totalHoras50
			,TotalMinutos50 = @totalMinutos50
			,TotalHoras100 = @totalHoras100
			,TotalMinutos100 = @totalMinutos100
			,FechaRegistro = GETDATE()
			,UsuarioRegistro = @UsuarioId
		FROM	tbAprobaciones AS AP
		INNER	JOIN @InfoXml.nodes('/HOREXT')	AS M(X)
		ON		AP.CodigoEmp = M.X.value('@CODEMP', 'int')
		AND		AP.Anio = M.X.value('@ANIOPE', 'int')
		AND		AP.PeriodoId = M.X.value('@PERIOD', 'int')
	END
	ELSE
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
		)
		SELECT	 M.X.value('@CODEMP', 'int') AS 'CodigoEmp'
				,M.X.value('@ANIOPE', 'int') AS 'Anio'
				,M.X.value('@PERIOD', 'int') AS 'PeriodoId'
				,@totalHoras50		AS 'TotalHoras50'
				,@totalMinutos50	AS 'TotalMinutos50'
				,@totalHoras100		AS 'TotalHoras100'
				,@totalMinutos100	AS 'TotalMinutos100'
				,GETDATE()		AS 'FechaRegistro'
				,@UsuarioId		AS 'UsuarioRegistro'
				--Las aprobaciones previas se borran si se modifica algun registro
				,NULL			AS 'UsuarioSuper'
				,NULL			AS 'FechaSuper'
				,NULL			AS 'UsuarioJefe'
				,NULL			AS 'Fechajefe'
		FROM @InfoXml.nodes('/HOREXT') AS M(X) 
	END
	
	--Se actualizan los Atrasos
	Declare @CodigoEmp int
	SELECT @CodigoEmp = ISNULL(M.X.value('@CODEMP', 'int'),0) FROM @InfoXml.nodes('/HOREXT') AS M(X)
	EXEC spAprobacionesAtrasosActualizar @UsuarioId = @CodigoEmp

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
