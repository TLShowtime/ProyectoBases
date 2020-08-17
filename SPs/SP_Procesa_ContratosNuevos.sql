USE [Empresa]
GO
IF OBJECT_ID('[dbo].[SP_Procesa_ContratosNuevos ]') IS NOT NULL
BEGIN 
    DROP PROC [dbo].[SP_Procesa_ContratosNuevos ]  
END 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SP_Procesa_ContratosNuevos @inContratosNuevos NuevoContrato READONLY,@inFechaActual date
AS   
BEGIN 
	BEGIN TRY
		SET NOCOUNT ON 

		BEGIN TRAN
			INSERT INTO dbo.Contrato(IdCliente,IdTipoContrato,NumeroTelefono,Fecha,Activo)
			SELECT C.Id,T.Id,CN.Numero,@inFechaActual,1
			FROM @inContratosNuevos CN inner join dbo.Cliente C on CN.Identificacion = C.Identificacion
									   inner join dbo.TipoContrato T on CN.TipoTarifa = T.Id

		COMMIT
	END TRY
	BEGIN CATCH
		If @@TRANCOUNT > 0 
			ROLLBACK TRAN;
		THROW;
	END CATCH
END
