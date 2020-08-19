Use [Empresa]
GO
IF OBJECT_ID('[dbo].[SP_Generar_Facturas]') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Generar_Facturas]
END
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SP_Generar_Facturas @inFechaActual DATE
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON

		DECLARE @FacturasACerrar TABLE (Id int not null identity(1,1),IdFactura int not null,IdContrato int null);
		DECLARE @DatosMinutosMegas TABLE (Id int not null identity(1,1),IdContrato int not null,IdTipoContrato int not null,IdConceptoTarifa int not null,Valor real);
		DECLARE @DatosMontos TABLE (Id int not null identity(1,1),IdContrato int not null,IdTipoContrato int not null,IdConceptoTarifa int not null,Valor real);
		DECLARE @Totales TABLE (Id int not null identity(1,1),IdContrato int not null,IdTipoContrato int not null,IdConceptoTarifa int not null,MontoTotal real);
		
		--- Busca las facturas que se "cierran" cada mes dependiendo de la fecha del contrato
		--  El dateadd ya contempla el caso en el que los dias sean al final del mes
		INSERT INTO @FacturasACerrar (IdFactura,IdContrato)
		SELECT F.Id,F.IdContrato
		FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id
		WHERE dateadd(month,1,F.Fecha) = @inFechaActual AND F.EstaCerrado = 0

		IF NOT EXISTS (SELECT F.Id from @FacturasACerrar F)
		BEGIN 
			RETURN 0
		END

		-------- Este solo incluye solo cantidad de minutos, megas y costo recargo por no pagar
		--- IDContrato,IdTipoContrato,IdConceptoTarifa,Valor
		INSERT INTO @DatosMinutosMegas (IdContrato,IdTipoContrato,IdConceptoTarifa,Valor)
		SELECT C.Id,T.Id,TXC.IdConceptoTarifa,TXC.Valor
		FROM dbo.Contrato C inner join @FacturasACerrar F on C.Id = F.IdContrato,
			 dbo.TipoContratoXConceptoTarifa TXC inner join dbo.TipoContrato T  on TXC.IdTipoContrato = T.Id
												 inner join dbo.ConceptoTarifa CT on TXC.IdConceptoTarifa =CT.Id
		WHERE C.IdTipoContrato = T.Id AND CT.Unidad= 'Integer'-- and C.NumeroTelefono = '90065559901'

		-------- Este solo incluye lo que son montos y no cantidad de minutos, megas que tenga disponible, ni costo por tardia
		--- IDContrato,IdTipoContrato,IdConceptoTarifa,Valor 
		INSERT INTO @DatosMontos (IdContrato,IdTipoContrato,IdConceptoTarifa,Valor)
		SELECT C.Id,T.Id,TXC.IdConceptoTarifa,TXC.Valor
		FROM dbo.Contrato C inner join @FacturasACerrar F on C.Id = F.IdContrato,
			 dbo.TipoContratoXConceptoTarifa TXC inner join dbo.TipoContrato T  on TXC.IdTipoContrato = T.Id
												 inner join dbo.ConceptoTarifa CT on TXC.IdConceptoTarifa =CT.Id
		WHERE C.IdTipoContrato = T.Id AND CT.Unidad != 'Integer'-- and C.NumeroTelefono = '90065559901'

		INSERT INTO @Totales (IdContrato,IdTipoContrato,IdConceptoTarifa,MontoTotal)
		SELECT D.IdContrato,D.IdTipoContrato,D.IdConceptoTarifa,CASE WHEN D.IdConceptoTarifa = 1 then D.Valor
																	-- Tarifa base						 
																	
																	 WHEN D.IdConceptoTarifa = 4 AND DMM.IdConceptoTarifa=2 AND F.SaldoMinutos > DMM.Valor then D.Valor * (F.SaldoMinutos - DMM.Valor)
																	 -- Costo minuto adicional
																	 
																	 WHEN D.IdConceptoTarifa = 5 AND DMM.IdConceptoTarifa=2 AND F.SaldoMinutos > DMM.Valor AND F.SaldoMinutos - DMM.Valor > 0 AND F.SaldoMinutosNocturno>0 then D.Valor * ((F.SaldoMinutos - DMM.Valor) + F.SaldoMinutosNocturno/2)
																	 -- Costo minuto nocturno adicional si hay minutos sobrantes despues de extraer el saldo de minutos con la cantidad base

																	 WHEN D.IdConceptoTarifa = 5 AND DMM.IdConceptoTarifa=2 AND F.SaldoMinutos <=0 AND F.SaldoMinutosNocturno/2 > DMM.Valor then D.Valor * (F.SaldoMinutosNocturno/2 - DMM.Valor)
																	-- Costo minuto nocturno adicional si no hay minutos normales acumulados
																	 
																	 WHEN D.IdConceptoTarifa = 6 AND DMM.IdConceptoTarifa=3 AND F.SaldoUsoMega > DMM.Valor then D.Valor * (F.SaldoUsoMega - DMM.Valor)
																	 -- Costo adicional por megas adicionales
																	
																	WHEN D.IdConceptoTarifa = 8 AND DMM.IdConceptoTarifa=2 AND F.SaldoMinutos <= DMM.Valor then D.Valor * F.SaldoMinutos
																	 -- Costo de cada minuto normal
																	
																	WHEN D.IdConceptoTarifa = 9 AND T.Nombre LIKE '%Familiar%' then D.Valor
																	-- Recargo por paquete familiar
																	
																	WHEN D.IdConceptoTarifa = 11 THEN D.Valor
																	-- Recargo por 911

																	WHEN D.IdConceptoTarifa = 12 THEN D.Valor * F.SaldoMinutos110
																	-- Recargo por llamadas a 110
																	
																	ELSE D.Valor
																	 end
		FROM @DatosMontos D inner join @FacturasACerrar FC on D.IdContrato = FC.IdContrato
							inner join dbo.Facturas F on D.IdContrato = F.IdContrato and F.EstaCerrado = 0
							,@DatosMinutosMegas DMM
							,dbo.TipoContrato T
		WHERE D.IdTipoContrato = DMM.IdTipoContrato AND T.Id = DMM.IdTipoContrato;

		

		INSERT INTO @Totales (IdContrato,IdTipoContrato,IdConceptoTarifa,MontoTotal)
		SELECT D.IdContrato,D.IdTipoContrato,D.IdConceptoTarifa, CASE WHEN T.TipoTelefono = 2 THEN D.Valor * F.SaldoMinutos800
																	WHEN T.TipoTelefono = 3 THEN D.Valor * F.SaldoMinutos900
																	END
		FROM @DatosMontos D inner join @FacturasACerrar FC on D.IdContrato = FC.IdContrato
							inner join dbo.Facturas F on D.IdContrato = F.IdContrato and F.EstaCerrado = 0
							, dbo.TipoContrato T
		WHERE T.Id = D.IdTipoContrato AND D.IdTipoContrato >= 7;

		BEGIN TRAN
			-- Inicializa una factura nueva a los contratos que cierran hoy la factura
			INSERT INTO dbo.Facturas(IdContrato,Fecha,SaldoMinutos,SaldoMinutosNocturno,SaldoUsoMega,SaldoMinutos110,SaldoMinutos800,SaldoMinutos900,EstaCerrado,Activo)
			SELECT C.Id,@inFechaActual,0,0,0,0,0,0,0,1
			FROM dbo.Contrato C inner join @FacturasACerrar F on C.Id  = F.IdContrato;

			----------------------- MOVIMIENTOS PARA PONER EN 0 LOS SALDOS --------------------------------------------------------------
			INSERT INTO dbo.MovUsoMinutos(IdFactura,IdTipoMovimiento,Fecha,Telefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,'-','00:00:00','00:00:00',0,1
			FROM dbo.Facturas F inner join @FacturasACerrar FC on F.IdContrato = FC.IdContrato,dbo.TipoMovimiento TM
			WHERE TM.Nombre = 'Credito' AND F.Fecha = @inFechaActual AND F.EstaCerrado = 0;

			INSERT INTO dbo.MovUsoMinutosNocturno(IdFactura,IdTipoMovimiento,Fecha,Telefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,'-','00:00:00','00:00:00',0,1
			FROM dbo.Facturas F inner join @FacturasACerrar FC on F.IdContrato = FC.IdContrato,dbo.TipoMovimiento TM
			WHERE TM.Nombre = 'Credito' AND F.Fecha = @inFechaActual  AND F.EstaCerrado = 0;

			INSERT INTO dbo.MovUsoMega(IdFactura,IdTipoMovimiento,Fecha,Monto,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,0,1
			FROM dbo.Facturas F inner join @FacturasACerrar FC on F.IdContrato = FC.IdContrato,dbo.TipoMovimiento TM
			WHERE TM.Nombre = 'Credito' AND F.Fecha = @inFechaActual AND F.EstaCerrado = 0;

			INSERT INTO dbo.MovMinutos110(IdFactura,IdTipoMovimiento,Fecha,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,'00:00:00','00:00:00',0,1
			FROM dbo.Facturas F inner join @FacturasACerrar FC on F.IdContrato = FC.IdContrato,dbo.TipoMovimiento TM
			WHERE TM.Nombre = 'Credito' AND F.Fecha = @inFechaActual AND F.EstaCerrado = 0;

			INSERT INTO dbo.MovMinutos800(IdFactura,IdTipoMovimiento,Fecha,NumTelefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,'-','00:00:00','00:00:00',0,1
			FROM dbo.Facturas F inner join @FacturasACerrar FC on F.IdContrato = FC.IdContrato,dbo.TipoMovimiento TM
			WHERE TM.Nombre = 'Credito' AND F.Fecha = @inFechaActual AND F.EstaCerrado = 0;

			INSERT INTO dbo.MovMinutos900(IdFactura,IdTipoMovimiento,Fecha,NumTelefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,'-','00:00:00','00:00:00',0,1
			FROM dbo.Facturas F inner join @FacturasACerrar FC on F.IdContrato = FC.IdContrato,dbo.TipoMovimiento TM
			WHERE TM.Nombre = 'Credito' AND F.Fecha = @inFechaActual AND F.EstaCerrado = 0;
			---------------------------------------------------------------------------------------------------------------------------

			------------------- SE CREAN LAS FACTURAS ---------------------------------------------------------------
			INSERT INTO dbo.Factura(IdContrato,FechaPago,MontoTotalAPagar,Estado,Activo)
			SELECT T.IdContrato,@inFechaActual,sum(T.MontoTotal),0,1
			FROM @Totales T inner join @FacturasACerrar F on T.IdContrato = F.IdContrato
			GROUP BY T.IdContrato;
			---------------------------------------------------------------------------------------------------------
			

			-------------------- CREAN LOS DETALLES DE LA FACTURA ---------------------------------------------------
			INSERT INTO dbo.Detalle(IdConceptoTarifa,IdFactura,Monto,Activo)
			SELECT T.IdConceptoTarifa,F.Id,T.MontoTotal,1
			FROM @Totales T inner join dbo.Factura F on T.IdContrato = F.IdContrato;
			---------------------------------------------------------------------------------------------------------
			

			------------------ Cierra las facturas -------------------------------------------
			UPDATE dbo.Facturas
			SET [Facturas].EstaCerrado = 1
			FROM dbo.Facturas F inner join @FacturasACerrar FC on F.Id = FC.IdFactura AND F.Activo = 1
			-----------------------------------------------------------------------------------

		COMMIT
		RETURN 1 -- Exito
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT >0
			ROLLBACK TRAN
		PRINT('Hubo un error en la generacion de facturas');
		THROW 
	END CATCH
END;