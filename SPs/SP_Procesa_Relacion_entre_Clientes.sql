USE [Empresa]
GO
IF OBJECT_ID('[dbo].[SP_Procesa_Relacion_entre_Clientes ]') IS NOT NULL
BEGIN 
    DROP PROC [dbo].[SP_Procesa_Relacion_entre_Clientes ]  
END 
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SP_Procesa_Relacion_entre_Clientes @inRelacionesFamiliares RelacionFamiliar READONLY
AS   
BEGIN 
	BEGIN TRY
		SET NOCOUNT ON 

		BEGIN TRAN

			-- El de IdentificacionDe es considerado como el de agregacion e IdentificadoA como el de asociacion.
			-- Ej: Padre-Hijo o Hermano-Hermana
			INSERT INTO dbo.EsFamiliaDe(IdClienteAgregacion,IdClienteAsociacion,IdTipoRelacion,Activo)
			SELECT C_1.Id,C_2.Id,R_1.TipoRelacion,1
			FROM @inRelacionesFamiliares R_1 inner join dbo.Cliente C_1 on R_1.IdentificacionDe = C_1.Identificacion,
				 @inRelacionesFamiliares R_2 inner join dbo.Cliente C_2 on R_2.IdentificacionA = C_2.Identificacion
			WHERE R_1.Id = R_2.Id

		COMMIT
	END TRY
	BEGIN CATCH
		If @@TRANCOUNT > 0 
			ROLLBACK TRAN;
		THROW;
	END CATCH
END
