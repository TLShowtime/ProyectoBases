Use [Empresa]
GO
IF OBJECT_ID('[dbo].[SP_Procesa_Megas_Usados]') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Procesa_Megas_Usados]
END
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SP_Procesa_Megas_Usados @inDatosUsados UsoDatos READONLY,@inFechaActual DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		BEGIN TRAN
			-- Movimiento en el cual se aumenta el gasto de megas
			INSERT INTO dbo.MovUsoMega(IdFactura,IdTipoMovimiento,Fecha,Monto,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,CONVERT(real,D.CantidadMegas),1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id ,@inDatosUsados D,dbo.TipoMovimiento TM
			WHERE C.NumeroTelefono = D.Numero and TM.Nombre = 'Debito' AND F.EstaCerrado = 0;	

			-- Actualizacion del saldo de megas de la factura
			UPDATE dbo.Facturas
			SET [dbo].[Facturas].SaldoUsoMega += MM.Monto
			FROM dbo.Facturas F inner join dbo.MovUsoMega MM on F.Id = MM.IdFactura
			WHERE MM.Fecha = @inFechaActual AND F.EstaCerrado = 0

		COMMIT
		RETURN 1 -- Exito
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT >0
			ROLLBACK TRAN
		PRINT('Hubo un error en el procesamiento de Megas');
		THROW 
	END CATCH
END;
