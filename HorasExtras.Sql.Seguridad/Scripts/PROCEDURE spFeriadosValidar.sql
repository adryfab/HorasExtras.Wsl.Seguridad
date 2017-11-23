USE HorasExtSup
GO

-- ##SUMMARY Valida si la fecha enviada es feriado
-- ##AUTHOR  19/Sep/2017 Adriana Martinez
-- ##REMARKS 

--DROP PROCEDURE spFeriadosValidar

CREATE PROCEDURE spFeriadosValidar
	 @fecha		date
	,@localidad	int
	,@feriado	bit			OUTPUT
AS
BEGIN
	IF EXISTS (
		SELECT	1
		FROM	BIOMETRICO.TCONTROL.dbo.TBL_FESTIVOS FES
		WHERE	FES.D_FESTIVO = @fecha
		AND		(FES.D_LOCALIDAD = @localidad OR FES.D_LOCALIDAD = 0)
	)
	BEGIN
		SET @feriado = 1 --SI EXISTE
	END
	ELSE
	BEGIN
		SET @feriado = 0 --NO EXISTE
	END
END
GO
