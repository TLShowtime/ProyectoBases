USE [Empresa]
GO
IF OBJECT_ID('[dbo].[SP_Procesa_ClienteNuevo ]') IS NOT NULL
BEGIN 
    DROP PROC [dbo].[SP_Procesa_ClienteNuevo ]  
END 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SP_Procesa_ClienteNuevo @inClientesNuevos ClienteNuevo READONLY
AS   
BEGIN 
	BEGIN TRY
		SET NOCOUNT ON 

		BEGIN TRAN
			INSERT INTO dbo.Cliente (Nombre,Identificacion,Activo)
			SELECT C.Nombre,C.Identificacion,1
			FROM @inClientesNuevos C

		COMMIT
	END TRY
	BEGIN CATCH
		If @@TRANCOUNT > 0 
			ROLLBACK TRAN;
		THROW;
	END CATCH
END
