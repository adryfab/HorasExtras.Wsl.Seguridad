USE HorasExtSup
GO

-- ##SUMMARY Verifica si el usuario es supervisor o jefe aprobador
-- ##AUTHOR  23/Nov/2017 Adriana Martinez
-- ##REMARKS 

--DROP PROCEDURE spUsuarioAprobador

CREATE PROCEDURE spUsuarioAprobador
	 @UsuarioId VARCHAR(50) 
	,@Aprobador bit			OUTPUT
AS
BEGIN
	--Obtiene el codigo del empleado
	DECLARE @CodEmp int
	SELECT	@CodEmp	 = @UsuarioId

	--Se verifica si el usuario es aprobador de departamento (Supervisor)
	IF EXISTS(SELECT 1 FROM BIOMETRICO.ONLYCONTROL.dbo.DPTO WHERE DEP_EM = @CodEmp)
	BEGIN
		SELECT @Aprobador = 1 
	END
	ELSE
	BEGIN
		--Se verifica si el usuario es aprobador de area (Jefe)
		IF EXISTS(SELECT 1 FROM BIOMETRICO.ONLYCONTROL.dbo.AREA WHERE AREA_EM = @CodEmp)
		BEGIN
			SELECT @Aprobador = 1 
		END
		ELSE
		BEGIN
			SELECT @Aprobador = 0 
		END
	END
END
