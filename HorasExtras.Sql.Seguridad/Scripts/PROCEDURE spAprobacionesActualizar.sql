USE HorasExtSup
GO

-- ##SUMMARY Consulta información registrada en biométrico
-- ##AUTHOR  14/Sep/2017 Adriana Martinez
-- ##REMARKS 

--DROP PROCEDURE spAprobacionesActualizar

CREATE PROCEDURE spAprobacionesActualizar
	 @InfoXml		xml
AS
BEGIN TRY
	BEGIN TRAN
		UPDATE tbAprobaciones
		SET
			 UsuarioSuper = (CASE WHEN M.X.value('@SUPERV', 'bit') = 1 THEN M.X.value('@USUSUP', 'VARCHAR(50)') ELSE UsuarioSuper END)
			,FechaSuper = (CASE WHEN M.X.value('@SUPERV', 'bit') = 1 THEN M.X.value('@FECSUP', 'DATETIME') ELSE FechaSuper END)
			,UsuarioJefe = (CASE WHEN M.X.value('@SUPERV', 'bit') = 0 THEN M.X.value('@USUJEF', 'VARCHAR(50)') ELSE UsuarioJefe END)
			,FechaJefe = (CASE WHEN M.X.value('@SUPERV', 'bit') = 0 THEN M.X.value('@FECJEF', 'DATETIME') ELSE FechaJefe END)
		FROM tbAprobaciones AP
		INNER JOIN @InfoXml.nodes('/APROBA') AS M(X) 
		ON AP.CodigoEmp = M.X.value('@CODEMP', 'int')
		AND AP.Anio = M.X.value('@ANIOPE', 'int')
		AND AP.PeriodoId = M.X.value('@PERIOD', 'int')
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
