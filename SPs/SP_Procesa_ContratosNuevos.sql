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

			-- Inicializa una factura nueva a partir de la firma del contrato
			INSERT INTO dbo.Facturas(IdContrato,Fecha,SaldoMinutos,SaldoMinutosNocturno,SaldoUsoMega,SaldoMinutos110,SaldoMinutos800,SaldoMinutos900,Activo)
			SELECT C.Id,@inFechaActual,0,0,0,0,0,0,1
			FROM dbo.Contrato C, @inContratosNuevos CN inner join dbo.Cliente CL on CN.Identificacion = CL.Identificacion
			WHERE C.IdCliente = CL.Id;

			-------- MOVIMIENTOS INICIALES PARA CADA FACTURA--------------------------------------------------------------------------
			INSERT INTO dbo.MovUsoMinutos(IdFactura,IdTipoMovimiento,Fecha,Telefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,'-','00:00:00','00:00:00',0,1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id
			    ,@inContratosNuevos CN inner join dbo.Cliente CL on CN.Identificacion = CL.Identificacion
				,dbo.TipoMovimiento TM
			WHERE C.IdCliente = CL.Id and TM.Nombre = 'Credito';

			INSERT INTO dbo.MovUsoMinutosNocturno(IdFactura,IdTipoMovimiento,Fecha,Telefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,'-','00:00:00','00:00:00',0,1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id
			    ,@inContratosNuevos CN inner join dbo.Cliente CL on CN.Identificacion = CL.Identificacion
				,dbo.TipoMovimiento TM
			WHERE C.IdCliente = CL.Id and TM.Nombre = 'Credito';

			
			INSERT INTO dbo.MovUsoMega(IdFactura,IdTipoMovimiento,Fecha,Monto,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,0,1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id
			    ,@inContratosNuevos CN inner join dbo.Cliente CL on CN.Identificacion = CL.Identificacion
				,dbo.TipoMovimiento TM
			WHERE C.IdCliente = CL.Id and TM.Nombre = 'Credito';

			INSERT INTO dbo.MovMinutos110(IdFactura,IdTipoMovimiento,Fecha,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,'00:00:00','00:00:00',0,1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id
			    ,@inContratosNuevos CN inner join dbo.Cliente CL on CN.Identificacion = CL.Identificacion
				,dbo.TipoMovimiento TM
			WHERE C.IdCliente = CL.Id and TM.Nombre = 'Credito';

			
			INSERT INTO dbo.MovMinutos800(IdFactura,IdTipoMovimiento,Fecha,NumTelefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,'-','00:00:00','00:00:00',0,1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id
			    ,@inContratosNuevos CN inner join dbo.Cliente CL on CN.Identificacion = CL.Identificacion
				,dbo.TipoMovimiento TM
			WHERE C.IdCliente = CL.Id and TM.Nombre = 'Credito';

			
			INSERT INTO dbo.MovMinutos900(IdFactura,IdTipoMovimiento,Fecha,NumTelefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,'-','00:00:00','00:00:00',0,1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id
			    ,@inContratosNuevos CN inner join dbo.Cliente CL on CN.Identificacion = CL.Identificacion
				,dbo.TipoMovimiento TM
			WHERE C.IdCliente = CL.Id and TM.Nombre = 'Credito';
			----------------------------------------------------------------------------------------------------------------
		COMMIT
	END TRY
	BEGIN CATCH
		If @@TRANCOUNT > 0 
			ROLLBACK TRAN;
		THROW;
	END CATCH
END


