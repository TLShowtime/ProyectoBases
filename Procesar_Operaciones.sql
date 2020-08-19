USE [Empresa]

DELETE dbo.Detalle
DELETE dbo.Factura

DELETE dbo.MovUsoMinutosNocturno
DELETE dbo.MovUsoMinutos
DELETE dbo.MovUsoMega
DELETE dbo.MovMinutos900
DELETE dbo.MovMinutos800
DELETE dbo.MovMinutos110

DELETE dbo.Facturas
DELETE dbo.EsFamiliaDe
DELETE dbo.Contrato
DELETE dbo.Cliente


--------- TABLAS TEMPORALES ---------------------------
DECLARE @Fechas table (id int identity(1,1) not null,Fecha date not null)



-------- VARIABLES ------------------------------
DECLARE @XMLData XML
		,@hdoc int
		,@fechaini date
		,@fechafin date

DECLARE @Clientes ClienteNuevo
		,@Contratos NuevoContrato
		,@RelacionesNuevas RelacionFamiliar
		,@LlamadasHechas LlamadaTelefonica
		,@DatosUsados UsoDatos
		,@FacturasAPagar PagoFactura;
------------------------------------------------------


SET NOCOUNT ON

--------------- Abre el XML ---------------------
SELECT @XMLData = C
FROM OPENROWSET (BULK 'C:\ProyectoBases\XML\Operaciones.xml',SINGLE_BLOB) AS Operaciones(C)
EXEC sp_xml_preparedocument @hdoc OUTPUT,@XMLData

-------------------- Obtiene todas las fechas de Operacion para la iteracion dia a dia -----------------
INSERT INTO @Fechas(Fecha)
SELECT Fecha1
FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia',1)
WITH (
	Fecha1 date '@fecha'
);

SELECT @fechaini = min(F.Fecha)
FROM @Fechas F

SELECT @fechafin = max(F.Fecha)
FROM @Fechas F


-------------Comienza la Simulacion
WHILE @fechaini <= @fechafin
BEGIN
	PRINT(@fechaIni)
	-- Obtiene los clientes nuevos del XML
	INSERT INTO @Clientes (Nombre,Identificacion)
	SELECT Nombre1,Identificacion1
	FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/ClienteNuevo',1)
	WITH (
		Identificacion1 varchar(10) '@Identificacion',
		Nombre1 varchar(100) '@Nombre',
		Fecha date '../@fecha'
	) 
	WHERE @fechaIni = Fecha;

	-- Inserta los nuevos clientes -------------------
	EXEC SP_Procesa_ClienteNuevo @Clientes;
	--------------------------------------------------


	--  Obtiene los contratos nuevos del XML
	INSERT INTO @Contratos (Identificacion, Numero, TipoTarifa)
	SELECT Identificacion2,Telefono,TipoTarifa1
	FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/NuevoContrato',1)
	WITH (
		Identificacion2 varchar(10) '@Identificacion',
		Telefono varchar(50) '@Numero',
		TipoTarifa1 int '@TipoTarifa',
		Fecha date '../@fecha'
	) 
	WHERE @fechaIni = Fecha;


	------------- Inserta los nuevos Contratos --------------
	EXEC SP_Procesa_ContratosNuevos @Contratos,@fechaini
	---------------------------------------------------------

	--  Obtiene las relaciones nuevas del XML
	INSERT INTO @RelacionesNuevas(IdentificacionDe,IdentificacionA,TipoRelacion)
	SELECT IdentificacionDe1,IdentificacionA1,TipoRelacion1
	FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/RelacionFamiliar',1)
	WITH (
		IdentificacionDe1 varchar(10) '@IdentificacionDe',
		IdentificacionA1 varchar(10) '@IdentificacionA',
		TipoRelacion1 int '@TipoRelacion',
		Fecha date '../@fecha'
	) 
	WHERE @fechaIni = Fecha;

	------------- Inserta las nuevas relaciones --------------
	EXEC SP_Procesa_Relacion_entre_Clientes @RelacionesNuevas
	----------------------------------------------------------

	-- <LlamadaTelefonica NumeroDe="65554137" NumeroA="75553737" Inicio="14:12" Fin="20:19"/>
	INSERT INTO @LlamadasHechas(NumeroDe,NumeroA,Inicio,Fin)
	SELECT NUmeroEmisor,NumeroReceptor,HoraInicio,HoraFin
	FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/LlamadaTelefonica',1)
	WITH (
		NumeroEmisor varchar(20) '@NumeroDe',
		NumeroReceptor varchar(20) '@NumeroA',
		HoraInicio time '@Inicio',
		HoraFin time '@Fin',
		Fecha date '../@fecha'
	) 
	WHERE @fechaIni = Fecha;

	-----------------
	EXEC SP_Procesa_Llamadas @LlamadasHechas,@fechaIni
	--------------------


	--<UsoDatos Numero="65558743" CantMegas="39.03"/>
	--Numero varchar(20) not null, CantidadMegas real not null);
	INSERT INTO @DatosUsados(Numero,CantidadMegas)
	SELECT NUmero,CantMegas
	FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/UsoDatos',1)
	WITH (
		Numero varchar(20) '@Numero',
		CantMegas real '@CantMegas',
		Fecha date '../@fecha'
	) 
	WHERE @fechaIni = Fecha;

	------------------------- Procesa los megas del XML -----------
	EXEC SP_Procesa_Megas_Usados @DatosUsados,@fechaIni
	---------------------------------------------------------------------

	
	----------------------------
	-- Generacion de facturas

	EXEC SP_Generar_Facturas @fechaIni
	---------------------------

	-------------- ------------- XML ---------------------------------- 
	INSERT INTO @FacturasAPagar(Numero)
	SELECT NUmero
	FROM OPENXML (@hdoc, '/Operaciones_por_Dia/OperacionDia/PagoFactura',1)
	WITH (
		Numero varchar(20) '@Numero',
		Fecha date '../@fecha'
	) 
	WHERE @fechaIni = Fecha;
	------------------------------------------------------------------

	-------- Procesa los pagos de factura -----------------
	EXEC SP_Procesa_Pago_Facturas @FacturasAPagar
	-------------------------

	DELETE @Clientes;
	DELETE @Contratos;
	DELETE @RelacionesNuevas;
	DELETE @LlamadasHechas;
	DELETE @DatosUsados;
	DELETE @FacturasAPagar;

	-- Pasa al siguiente dia
	SET @fechaini = dateadd(day,1,@fechaini)
END;

-- Cierra el Archivo XML
EXEC sp_xml_removedocument @hdoc;