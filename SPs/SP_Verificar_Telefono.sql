Use [Empresa]
GO
IF OBJECT_ID('[dbo].[SP_Verificar_Telefono]') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Verificar_Telefono]
END
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SP_Verificar_Telefono @inTelefono varchar(20),@outIdTelefono INT OUTPUT
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		DECLARE @existeTelefono int
		
		SELECT @existeTelefono = C.Id
		FROM dbo.Contrato C 
		WHERE C.NumeroTelefono = @inTelefono

		IF @existeTelefono <= 0 OR @existeTelefono IS NULL
		BEGIN
			RETURN -1
		END;

		SELECT @outIdTelefono = @existeTelefono

		RETURN 1 -- Exito
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT >0
			ROLLBACK TRAN
		PRINT('Hubo un error');
		THROW 
	END CATCH
END;

DECLARE @id int

EXEC SP_Verificar_Telefono '85558939',@id OUTPUT

PRINT(@id)

SELECT F.MontoTotalAPagar,F.FechaPago FROM dbo.Factura F inner join dbo.Contrato C on F.IdContrato = C.Id WHERE F.Estado = 0 AND F.Activo = 1

SELECT C.Nombre,D.Monto
FROM dbo.Detalle D inner join dbo.ConceptoTarifa C on D.IdConceptoTarifa = C.Id 
WHERE D.IdFactura = 9
