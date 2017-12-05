USE HorasExtSup
GO

-- ##SUMMARY Inserta la información registrada por el usuario en la tabla de HorasExtras
-- ##AUTHOR  11/Sep/2017 Adriana Martinez
-- ##REMARKS 
-- ##HISTORY 28/Nov/2017 Adriana Martinez
-- ##HISTORY Añadida columna Aprobado y cambiado SP Aprobaciones

ALTER PROCEDURE spHorasExtrasAgregar
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
			,Aprobado
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
			,Aprobado		= M.X.value('@APROBA', 'bit')
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
			,Aprobado		= M.X.value('@APROBA', 'bit')
		FROM tbHorasExtras HE 
		INNER JOIN @InfoXml.nodes('/HOREXT') AS M(X) 
		ON HE.HorasExtrasId = M.X.value('@HOREXT', 'bigint')

		SELECT @HorasExtrasId = 1
	END

	--Se actualizan las Aprobaciones
	Declare @CodigoEmp int
	SELECT @CodigoEmp = ISNULL(M.X.value('@CODEMP', 'int'),0) FROM @InfoXml.nodes('/HOREXT') AS M(X)
	EXEC spAprobacionesAgregar @UsuarioId = @CodigoEmp, @InfoXml = @InfoXml
	
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
