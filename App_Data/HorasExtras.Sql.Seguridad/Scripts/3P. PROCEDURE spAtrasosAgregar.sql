USE HorasExtSup
GO

-- ##SUMMARY Inserta la información registrada por el usuario en la tabla de Atrasos
-- ##AUTHOR  24/Nov/2017 Adriana Martinez
-- ##REMARKS 

--DROP PROCEDURE spAtrasosAgregar

CREATE PROCEDURE spAtrasosAgregar
	 @UsuarioId		varchar(50) 
	,@InfoXml		xml
	,@AtrasosId		bigint		OUTPUT
AS
BEGIN TRY
	--Se verifica si existe el registro
	SELECT @AtrasosId = ISNULL(M.X.value('@ATRAID', 'bigint'),0) FROM @InfoXml.nodes('/ATRASO') AS M(X)

	BEGIN TRAN

	IF @AtrasosId = 0 --No existe
	BEGIN
		--Se realiza la inserción de los datos a partir del XML.	
		INSERT INTO	tbAtrasos
		(
			 UsuarioId
			,CodigoEmp
			,Anio
			,PeriodoId
			,Fecha
			,Ingreso
			,Tiempo
			,CodNovedad
			,DetNovedad
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
			,Ingreso		= M.X.value('@INGRES', 'datetime')
			,Tiempo			= M.X.value('@TIEMPO', 'datetime')
			,CodNovedad		= M.X.value('@CODNOV', 'varchar(2)')
			,DetNovedad		= M.X.value('@DETNOV', 'varchar(30)')
			,Descripcion	= M.X.value('@JUSTIF', 'varchar(MAX)')
			,Activo			= M.X.value('@ACTIVO', 'bit')
			,Biometrico		= M.X.value('@BIOMET', 'bit')
			,Aprobado		= M.X.value('@APROBA', 'bit')
		FROM @InfoXml.nodes('/ATRASO')	AS M(X) 	
		
		SELECT @AtrasosId = @@IDENTITY
	END
	ELSE --Si Existe
	BEGIN
		UPDATE tbAtrasos
		SET	 UsuarioId		= @UsuarioId
			,CodigoEmp		= M.X.value('@CODEMP', 'int')
			,Anio			= M.X.value('@ANIOPE', 'int')
			,PeriodoId		= M.X.value('@PERIOD', 'int')
			,Fecha			= M.X.value('@FECHAM', 'date')
			,Ingreso		= M.X.value('@INGRES', 'datetime')
			,Tiempo			= M.X.value('@TIEMPO', 'datetime')
			,CodNovedad		= M.X.value('@CODNOV', 'varchar(2)')
			,DetNovedad		= M.X.value('@DETNOV', 'varchar(30)')
			,Descripcion	= M.X.value('@JUSTIF', 'varchar(MAX)')
			,Activo			= M.X.value('@ACTIVO', 'bit')
			,Biometrico		= M.X.value('@BIOMET', 'bit')
			,Aprobado		= M.X.value('@APROBA', 'bit')
		FROM tbAtrasos ATR 
		INNER JOIN @InfoXml.nodes('/ATRASO') AS M(X) 
		ON ATR.AtrasosId = M.X.value('@ATRAID', 'bigint')

		SELECT @AtrasosId = 1
	END

	--Se actualizan las aprobaciones
	EXEC spAprobacionesAtrasosActualizar @UsuarioId = @UsuarioId

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
