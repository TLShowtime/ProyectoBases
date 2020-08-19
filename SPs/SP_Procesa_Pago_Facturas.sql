Use [Empresa]
GO
IF OBJECT_ID('[dbo].[SP_Procesa_Pago_Facturas]') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Procesa_Pago_Facturas]
END
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SP_Procesa_Pago_Facturas @FacturasAPagar PagoFactura READONLY
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		IF NOT EXISTS (SELECT F.id FROM @FacturasAPagar F)
		BEGIN
			RETURN 0
		END;

		DECLARE @FacturasPendientes TABLE (id int identity(1,1) not null, IdFactura int)

		DECLARE @lastNumber int, @actualNumber int

		SELECT @lastNumber = max(F.id), @actualNumber = min(F.id)
		from @FacturasAPagar F

		WHILE @actualNumber <= @lastNumber
		BEGIN
			-- Busca la factura hecha antes por cada numero
			INSERT INTO @FacturasPendientes(IdFactura)
			SELECT min(F.Id)
			FROM  @FacturasAPagar FP inner join dbo.Contrato C on FP.Numero = C.NumeroTelefono
									 inner join dbo.Factura F on C.Id = F.IdContrato
			WHERE FP.id = @actualNumber and F.Estado = 0 and F.Activo = 1;

			-- Cambia de numero
			SET @actualNumber += 1;
		END
		
	
		BEGIN TRAN
			UPDATE dbo.Factura
			SET [Factura].Estado = 1
			from @FacturasPendientes FP 
			WHERE FP.IdFactura = [Factura].Id AND FP.IdFactura IS NOT NULL
	
		COMMIT
		RETURN 1 -- Exito
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT >0
			ROLLBACK TRAN
		PRINT('Hubo un error en el pago de facturas');
		THROW 
	END CATCH
END;
