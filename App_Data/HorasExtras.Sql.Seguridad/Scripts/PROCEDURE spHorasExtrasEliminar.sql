USE HorasExtSup
GO

-- ##SUMMARY Elimina la informaci�n registrada por el usuario en la tabla de HorasExtras
-- ##AUTHOR  12/Sep/2017 Adriana Martinez
-- ##REMARKS 
-- ##HISTORY 29/Nov/2017 Adriana Martinez
-- ##HISTORY A�adido SP Aprobaciones

ALTER PROCEDURE spHorasExtrasEliminar
	 @UsuarioId		varchar(50) 
	,@InfoXml		xml
AS
BEGIN TRY
	BEGIN TRAN
	--Se realiza la eliminacion
	DELETE	HE
	FROM	tbHorasExtras AS HE
	INNER	JOIN @InfoXml.nodes('/HOREXT')	AS M(X)
	ON		HE.HorasExtrasId	= M.X.value('@HOREXT', 'bigint')
	--AND		HE.UsuarioId		= @UsuarioId
	AND		HE.CodigoEmp		= @UsuarioId

	--Se actualizan las Aprobaciones
	EXEC spAprobacionesAgregar @UsuarioId = @UsuarioId, @InfoXml = @InfoXml

	--Se procesa la transacci�n.
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
