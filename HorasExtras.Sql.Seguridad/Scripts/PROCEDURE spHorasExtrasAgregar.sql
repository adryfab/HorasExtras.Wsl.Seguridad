USE HorasExtSup
GO

-- ##SUMMARY Inserta la información registrada por el usuario en la tabla de HorasExtras
-- ##AUTHOR  11/Sep/2017 Adriana Martinez
-- ##REMARKS 

--DROP PROCEDURE spHorasExtrasAgregar

CREATE PROCEDURE spHorasExtrasAgregar
	 @UsuarioId		varchar(50) 
	,@InfoXml		xml
	,@HorasExtrasId	bigint		OUTPUT
AS
BEGIN TRY
	--Se verifica si existe el registro
	SELECT @HorasExtrasId = ISNULL(M.X.value('@HOREXT', 'bigint'),0) FROM @InfoXml.nodes('/HOREXT') AS M(X)

	BEGIN TRAN

	IF @HorasExtrasId = 0 --No existe
	BEGIN
		--Se realiza la inserción de los datos a partir del XML.	
		INSERT INTO	tbHorasExtras
		(
			 UsuarioId 
			,CodigoEmp 
			,Anio 
			,PeriodoId 
			,Fecha 
			,HoraIngreso 
			,HoraSalida 
			,HoraLaborado 
			,HoraAtrasado 
			,HoraAnticipado 
			,Horas0 
			,Horas50 
			,Horas100 
			,HorasPermiso
			,HorasRecuperar
			,Descripcion 
			,Activo
			,Biometrico
		)
		SELECT 
			 UsuarioId		= @UsuarioId
			,CodigoEmp		= M.X.value('@CODEMP', 'int')
			,Anio			= M.X.value('@ANIOPE', 'int')
			,PeriodoId		= M.X.value('@PERIOD', 'int')
			,Fecha			= M.X.value('@FECHAM', 'date')
			,HoraIngreso	= M.X.value('@INGRES', 'time(0)')
			,HoraSalida		= M.X.value('@SALIDA', 'time(0)')
			,HoraLaborado	= M.X.value('@LABORA', 'time(0)')
			,HoraAtrasado	= M.X.value('@ATRASA', 'time(0)')
			,HoraAnticipado = M.X.value('@ANTICI', 'time(0)')
			,Horas0			= M.X.value('@HORA00', 'time(0)')
			,Horas50		= M.X.value('@HORA50', 'time(0)')
			,Horas100		= M.X.value('@HOR100', 'time(0)')
			,HorasPermiso	= M.X.value('@HORPER', 'time(0)')
			,HorasRecuperar	= M.X.value('@HORREC', 'time(0)')
			,Descripcion	= M.X.value('@JUSTIF', 'varchar(MAX)')
			,Activo			= M.X.value('@ACTIVO', 'bit')
			,Biometrico		= M.X.value('@BIOMET', 'bit')
		FROM @InfoXml.nodes('/HOREXT')	AS M(X) 	
		
		SELECT @HorasExtrasId = @@IDENTITY
	END
	ELSE --Si Existe
	BEGIN
		UPDATE tbHorasExtras
		SET	 UsuarioId		= @UsuarioId
			,CodigoEmp		= M.X.value('@CODEMP', 'int')
			,Anio			= M.X.value('@ANIOPE', 'int')
			,PeriodoId		= M.X.value('@PERIOD', 'int')
			,Fecha			= M.X.value('@FECHAM', 'date')
			,HoraIngreso	= M.X.value('@INGRES', 'time(0)')
			,HoraSalida		= M.X.value('@SALIDA', 'time(0)')
			,HoraLaborado	= M.X.value('@LABORA', 'time(0)')
			,HoraAtrasado	= M.X.value('@ATRASA', 'time(0)')
			,HoraAnticipado = M.X.value('@ANTICI', 'time(0)')
			,Horas0			= M.X.value('@HORA00', 'time(0)')
			,Horas50		= M.X.value('@HORA50', 'time(0)')
			,Horas100		= M.X.value('@HOR100', 'time(0)')
			,HorasPermiso	= M.X.value('@HORPER', 'time(0)')
			,HorasRecuperar	= M.X.value('@HORREC', 'time(0)')
			,Descripcion	= M.X.value('@JUSTIF', 'varchar(MAX)')
			,Activo			= M.X.value('@ACTIVO', 'bit')
			,Biometrico		= M.X.value('@BIOMET', 'bit')
		FROM tbHorasExtras HE 
		INNER JOIN @InfoXml.nodes('/HOREXT') AS M(X) 
		ON HE.HorasExtrasId = M.X.value('@HOREXT', 'bigint')
	END

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

	DELETE	AP
	FROM	tbAprobaciones AS AP
	INNER	JOIN @InfoXml.nodes('/HOREXT')	AS M(X)
	ON		AP.CodigoEmp = M.X.value('@CODEMP', 'int')
	AND		AP.Anio = M.X.value('@ANIOPE', 'int')
	AND		AP.PeriodoId = M.X.value('@PERIOD', 'int')

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

	--Se procesa la transacción.		
    IF @@TRANCOUNT > 0 
	BEGIN
		COMMIT  TRAN 
	END
END TRY
BEGIN CATCH
	--En caso de error se realiza un rollback de la transaccion y se ejecuta el spError.
	IF @@TRANCOUNT > 0 
       ROLLBACK TRAN        
END CATCH
GO
