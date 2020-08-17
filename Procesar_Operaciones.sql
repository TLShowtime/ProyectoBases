USE [Empresa]

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
		,@RelacionesNuevas RelacionFamiliar;



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



	DELETE @Clientes
	DELETE @Contratos
	DELETE @RelacionesNuevas

	-- Pasa al siguiente dia
	SET @fechaini = dateadd(day,1,@fechaini)
END;

-- Cierra el Archivo XML
EXEC sp_xml_removedocument @hdoc;


/**
SELECT E1.Id,C1.Identificacion,C2.Identificacion,E1.IdTipoRelacion from dbo.EsFamiliaDe E1 inner join dbo.Cliente C1 on E1.IdClienteAgregacion = C1.Id,
			  dbo.EsFamiliaDe E2 inner join dbo.Cliente C2 on E2.IdClienteAsociacion = C2.Id
		where E1.Id = E2.Id
*/