Use [Empresa]
GO
IF OBJECT_ID('[dbo].[SP_Procesa_Llamadas]') IS NOT NULL
BEGIN
	DROP PROC [dbo].[SP_Procesa_Llamadas]
END
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROC SP_Procesa_Llamadas @inLlamadas LlamadaTelefonica READONLY,@inFechaActual date
AS
BEGIN
	BEGIN TRY
		SET NOCOUNT ON
		BEGIN TRAN
		-- <LlamadaTelefonica NumeroDe="65554137" NumeroA="75553737" Inicio="14:12" Fin="20:19"/>

		-- Movimiento en el cual se expresan los minutos normales 
			INSERT INTO dbo.MovUsoMinutos(IdFactura,IdTipoMovimiento,Fecha,Telefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,L.NumeroA,L.Inicio,L.Fin, CASE WHEN DATEDIFF(minute,L.Inicio,L.Fin) < 0 
																		then 1440 + DATEDIFF(minute,L.Inicio,L.Fin) 
																		else DATEDIFF(minute,L.Inicio,L.Fin) end,1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id ,@inLlamadas L,dbo.TipoMovimiento TM
			WHERE C.NumeroTelefono = L.NumeroDe and TM.Nombre = 'Debito' and NOT ((L.Inicio BETWEEN '23:00:00'AND'23:59:00' OR  L.Inicio BETWEEN '00:00:00'AND'05:00:00')  AND( L.Fin BETWEEN '23:00:00'AND'23:59:00' OR  L.Fin BETWEEN '00:00:00'AND'05:00:00')) and len(L.NumeroA) = 8 and F.EstaCerrado = 0;
			------------											---- Si al menos uno esta en la franja de normal, annaden como minutos normales


			---------------- Movimientos para minutos nocturnos 23:00-5:00
			INSERT INTO dbo.MovUsoMinutosNocturno(IdFactura,IdTipoMovimiento,Fecha,Telefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,L.NumeroA,L.Inicio,L.Fin, CASE WHEN DATEDIFF(minute,L.Inicio,L.Fin) < 0 
																		then 1440 + DATEDIFF(minute,L.Inicio,L.Fin) 
																		else DATEDIFF(minute,L.Inicio,L.Fin) end,1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id, @inLlamadas L,dbo.TipoMovimiento TM
			WHERE C.NumeroTelefono = L.NumeroDe and TM.Nombre = 'Debito' and (L.Inicio BETWEEN '23:00:00'AND'23:59:00' OR  L.Inicio BETWEEN '00:00:00'AND'05:00:00')  AND (L.Fin BETWEEN '23:00:00'AND'23:59:00' OR  L.Fin BETWEEN '00:00:00'AND'05:00:00') and len(L.NumeroA) = 8  and F.EstaCerrado = 0;
																				--- Si esta en la franja nocturna, los minutos seran nocturnos

			----------------- Movimientos relacionado a 110 ---------------------------------------------------------------
			INSERT INTO dbo.MovMinutos110(IdFactura,IdTipoMovimiento,Fecha,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,L.Inicio,L.Fin, CASE WHEN DATEDIFF(minute,L.Inicio,L.Fin) < 0 
																		then 1440 + DATEDIFF(minute,L.Inicio,L.Fin) 
																		else DATEDIFF(minute,L.Inicio,L.Fin) end,1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id,@inLlamadas L,dbo.TipoMovimiento TM
			WHERE C.NumeroTelefono = L.NumeroDe and TM.Nombre = 'Debito' and L.NumeroA = '110'  and F.EstaCerrado = 0;


			--------------------- Movimientos con numeros 900 -------------------------------------------------------------
			INSERT INTO dbo.MovMinutos900(IdFactura,IdTipoMovimiento,Fecha,NumTelefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,L.NumeroA,L.Inicio,L.Fin,CASE WHEN DATEDIFF(minute,L.Inicio,L.Fin) < 0 
																		then (1440 + DATEDIFF(minute,L.Inicio,L.Fin)) 
																		else (DATEDIFF(minute,L.Inicio,L.Fin)) end,1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id, @inLlamadas L, dbo.TipoMovimiento TM
			WHERE C.NumeroTelefono = L.NumeroDe and TM.Nombre = 'Debito' and len(L.NumeroA) = 11 and L.NumeroA LIKE '900%'  and F.EstaCerrado = 0;

			--------------------- Movimientos con numeros 800, este se le suma los minutos a la persona que se llama que tiene 800- -------------------------------------------------------------
			INSERT INTO dbo.MovMinutos800(IdFactura,IdTipoMovimiento,Fecha,NumTelefono,HoraInicio,HoraFinal,CantidadMinutos,Activo)
			SELECT F.Id,TM.Id,@inFechaActual,L.NumeroA,L.Inicio,L.Fin,CASE WHEN DATEDIFF(minute,L.Inicio,L.Fin) < 0 
																		then 1440 + DATEDIFF(minute,L.Inicio,L.Fin) 
																		else DATEDIFF(minute,L.Inicio,L.Fin) end,1
			FROM dbo.Facturas F inner join dbo.Contrato C on F.IdContrato = C.Id, @inLlamadas L, dbo.TipoMovimiento TM
			WHERE C.NumeroTelefono = L.NumeroA and TM.Nombre = 'Debito' and len(L.NumeroA) = 11 and L.NumeroA LIKE '800%' and F.EstaCerrado = 0;


			-------------------------- SE ACTUALIZAN LOS SALDOS QUE REGISTRARON UN MOVIMIENTO EN ESE DIA -------------------------------------
			UPDATE dbo.Facturas
			SET [dbo].[Facturas].SaldoMinutos += MM.CantidadMinutos 
			FROM dbo.Facturas F inner join dbo.MovUsoMinutos MM on F.Id = MM.IdFactura
			WHERE MM.Fecha = @inFechaActual  and F.EstaCerrado = 0

			UPDATE dbo.Facturas
			SET  [dbo].[Facturas].SaldoMinutosNocturno += MMN.CantidadMinutos
			FROM dbo.Facturas F inner join dbo.MovUsoMinutosNocturno MMN on F.Id = MMN.IdFactura
			WHERE MMN.Fecha = @inFechaActual AND F.EstaCerrado = 0
								
			UPDATE dbo.Facturas
			SET  [dbo].[Facturas].SaldoMinutos110 += M110.CantidadMinutos
			FROM dbo.Facturas F inner join dbo.MovMinutos110 M110 on F.Id = M110.IdFactura
			WHERE M110.Fecha = @inFechaActual AND F.EstaCerrado = 0

			UPDATE dbo.Facturas
			SET  [dbo].[Facturas].SaldoMinutos800 += M800.CantidadMinutos
			FROM dbo.Facturas F inner join dbo.MovMinutos800 M800 on F.Id = M800.IdFactura
								inner join dbo.MovMinutos900 M900 on F.Id = M900.IdFactura
			WHERE M800.Fecha = @inFechaActual AND F.EstaCerrado = 0

			UPDATE dbo.Facturas
			SET  [dbo].[Facturas].SaldoMinutos800 += M900.CantidadMinutos
			FROM dbo.Facturas F inner join dbo.MovMinutos900 M900 on F.Id = M900.IdFactura
			WHERE M900.Fecha = @inFechaActual AND F.EstaCerrado = 0
			----------------------------------------------------------------------------------------

		COMMIT
		RETURN 1 -- Exito
	END TRY

	BEGIN CATCH
		IF @@TRANCOUNT >0
			ROLLBACK TRAN
		PRINT('Hubo un error en el procesamiento de llamadas');
		THROW 
	END CATCH
END;

