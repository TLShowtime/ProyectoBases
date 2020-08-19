USE [Empresa]

/**
	DROP TABLE Mov900Externo
	DROP TABLE Mov800Externo
	DROP TABLE MovPersonalExterno
	DROP TABLE FacturaExterna
	DROP TABLE ContratoExterno
	DROP TABLE EmpresaExterna
	DROP TABLE MovMinutos900
	DROP TABLE MovMinutos800
	DROP TABLE MovMinutos110
	DROP TABLE MovUsoMinutosNocturno
	DROP TABLE MovUsoMinutos
	DROP TABLE MovUsoMega
	DROP TABLE Facturas
	DROP TABLE TipoMovimiento
	DROP TABLE Detalle
	DROP TABLE Factura
	DROP TABLE Contrato
	DROP TABLE MontoDineroPorcentaje
	DROP TABLE MontoDineroFijo
	DROP TABLE MontoMinutoFijo
	DROP TABLE MontoMegaFijo
	DROP TABLE TipoContratoXConceptoTarifa
	DROP TABLE ConceptoTarifa
	DROP TABLE TipoContrato
	DROP TABLE EsFamiliaDe
	DROP TABLE TipoRelacion
	DROP TABLE Cliente
*/


------------------------ RELACION ENTRE CLIENTES
CREATE TABLE Cliente(
	Id int not null Primary Key identity(1,1),
	Nombre varchar(100) not null,
	Identificacion varchar(10) not null,
	Activo int not null
);

CREATE TABLE TipoRelacion(
	Id int not null Primary Key,
	Nombre varchar(50) not null,
	Activo int not null
);

CREATE TABLE EsFamiliaDe(
	Id int identity(1,1) Primary Key not null,
	IdClienteAgregacion int not null Foreign Key references Cliente(Id),
	IdClienteAsociacion int not null Foreign Key references Cliente(Id),
	IdTipoRelacion int not null Foreign Key references TipoRelacion(Id),
	Activo int not null
);
---------------------------------------------------------------------


-------------- Configuracion de tarifas ---------------------------------
/**
	Tipo Tarifa
	
	TipoTelefono
	1. Personal
	2. 800
	3. 900
*/
CREATE TABLE TipoContrato (
	Id int not null Primary Key,
	Nombre varchar(50) not null,
	TipoTelefono int not null,
	Activo int not null
);

-- Tipo Elemento en XML
CREATE TABLE ConceptoTarifa(
	Id int Primary Key not null,
	Nombre varchar(100) not null,
	Unidad varchar(30) not null,
	Activo int not null
);

CREATE TABLE TipoContratoXConceptoTarifa(
	Id int identity(1,1) not null Primary Key,
	IdTipoContrato int not null Foreign Key references TipoContrato(Id),
	IdConceptoTarifa int not null Foreign Key references ConceptoTarifa(Id),
	Valor real,
	Activo int not null
);

CREATE TABLE MontoMegaFijo(
	Id int not null Primary Key Foreign Key references TipoContratoXConceptoTarifa(Id),
	Activo int not null
);
CREATE TABLE MontoMinutoFijo(
	Id int not null Primary Key Foreign Key references TipoContratoXConceptoTarifa(Id),
	Activo int not null
);
CREATE TABLE MontoDineroFijo(
	Id int not null Primary Key Foreign Key references TipoContratoXConceptoTarifa(Id),
	Activo int not null
);
CREATE TABLE MontoDineroPorcentaje(
	Id int not null Primary Key Foreign Key references TipoContratoXConceptoTarifa(Id),
	Activo int not null
);

------------------------------------------------------------------------------

------------------- Facturas que se crean -------------------------------------
CREATE TABLE Contrato (
	Id int identity(1,1) not null Primary Key,
	IdCliente int not null Foreign Key references Cliente(Id),
	IdTipoContrato int not null Foreign Key references TipoContrato(Id),
	Fecha date not null,
	NumeroTelefono varchar(20) not null,
	Activo int not null
);


CREATE TABLE Factura(
	Id int not null identity(1,1) Primary Key,
	IdContrato int not null Foreign Key references Contrato(Id),
	MontoTotalAPagar money not null,
	Estado int not null,
	FechaPago date not null,
	Activo int not null
);

CREATE TABLE Detalle(
	Id int identity(1,1) Primary Key not null,
	IdConceptoTarifa int Foreign Key references ConceptoTarifa(Id),
	IdFactura int Foreign Key references Factura(Id),
	Monto money not null,
	Activo int not null
);
-------------------------------------------------------------------------

----------------- Acumulados de saldo y movimientos --------------------------
CREATE TABLE TipoMovimiento(
	Id int not null Primary Key,
	Nombre varchar(20) not null,
	Activo int not null
);

------ Estado en este caso es 0 si esta abierta o 1 si esta cerrado 
CREATE TABLE Facturas(
	Id int not null Primary Key identity(1,1),
	IdContrato int not null Foreign Key references Contrato(Id),
	Fecha date not null,
	SaldoUsoMega float not null,
	SaldoMinutos int not null,
	SaldoMinutosNocturno int not null,
	SaldoMinutos110 int not null,
	SaldoMinutos800 int not null,
	SaldoMinutos900 int not null,
	EstaCerrado int not null,
	Activo int not null
);

CREATE TABLE MovUsoMega(
	Id int not null Primary Key identity(1,1),
	IdFactura int not null Foreign Key references Facturas(Id),
	IdTipoMovimiento int not null Foreign Key references TipoMovimiento(Id),
	Fecha date not null,
	Monto real not null,
	Activo int not null
);

CREATE TABLE MovUsoMinutos(
	Id int not null Primary Key identity(1,1),
	IdFactura int not null Foreign Key references Facturas(Id),
	IdTipoMovimiento int not null Foreign Key references TipoMovimiento(Id),
	Fecha date not null,
	Telefono varchar(20) not null,
	HoraInicio time not null,
	HoraFinal time not null,
	CantidadMinutos int not null,
	Activo int not null
);

CREATE TABLE MovUsoMinutosNocturno(
	Id int not null Primary Key identity(1,1),
	IdFactura int not null Foreign Key references Facturas(Id),
	IdTipoMovimiento int not null Foreign Key references TipoMovimiento(Id),
	Fecha date not null,
	Telefono varchar(20) not null,
	HoraInicio time not null,
	HoraFinal time not null,
	CantidadMinutos int not null,
	Activo int not null
);

CREATE TABLE MovMinutos110(
	Id int not null Primary Key identity(1,1),
	IdFactura int not null Foreign Key references Facturas(Id),
	IdTipoMovimiento int not null Foreign Key references TipoMovimiento(Id),
	Fecha date not null,
	HoraInicio time not null,
	HoraFinal time not null,
	CantidadMinutos int not null,
	Activo int not null
);

CREATE TABLE MovMinutos800(
	Id int not null Primary Key identity(1,1),
	IdFactura int not null Foreign Key references Facturas(Id),
	IdTipoMovimiento int not null Foreign Key references TipoMovimiento(Id),
	Fecha date not null,
	NumTelefono varchar(20)not null,
	HoraInicio time not null,
	HoraFinal time not null,
	CantidadMinutos int not null,
	Activo int not null
);

CREATE TABLE MovMinutos900(
	Id int not null Primary Key identity(1,1),
	IdFactura int not null Foreign Key references Facturas(Id),
	IdTipoMovimiento int not null Foreign Key references TipoMovimiento(Id),
	Fecha date not null,
	NumTelefono varchar(20)not null,
	HoraInicio time not null,
	HoraFinal time not null,
	CantidadMinutos int not null,
	Activo int not null
);
---------------------------------------------------------------------------------

------------------------ Empresa Externa y Contrato Externo------------------------

-- Empresa X y Y
CREATE TABLE EmpresaExterna(
	Id int not null Primary Key identity(1,1),
	Nombre varchar(20) not null,
	Activo int not null
);

CREATE TABLE ContratoExterno(
	Id int not null Primary Key identity(1,1),
	IdEmpresaExterna int not null Foreign Key references EmpresaExterna(Id),
	FechaContratacion date not null,	
	Activo int not null
);
----------------------------------------------------------------------------

------------- Facturas Externas y Movimientos-------------------------------------------
CREATE TABLE FacturaExterna(
	Id int not null Primary Key identity(1,1),
	IdContratoExterno int not null Foreign Key references ContratoExterno(Id),
	SaldoMinutos800 int not null,
	SaldoMinutos900 int not null,
	SaldoMinutosPersonal int not null,
	Activo int not null
);

CREATE TABLE MovPersonalExterno(
	Id int not null Primary Key identity(1,1),
	IdFacturaExterna int not null Foreign Key references FacturaExterna(Id),
	IdTipoMovimiento int not null Foreign Key references TipoMovimiento(Id),
	HoraInicio time not null,
	HoraFinal time not null,
	CantidadMinutos int not null,
	Activo int not null
);

CREATE TABLE Mov800Externo(
	Id int not null Primary Key identity(1,1),
	IdFacturaExterna int not null Foreign Key references FacturaExterna(Id),
	IdTipoMovimiento int not null Foreign Key references TipoMovimiento(Id),
	HoraInicio time not null,
	HoraFinal time not null,
	CantidadMinutos int not null,
	Activo int not null
);

CREATE TABLE Mov900Externo(
	Id int not null Primary Key identity(1,1),
	IdFacturaExterna int not null Foreign Key references FacturaExterna(Id),
	IdTipoMovimiento int not null Foreign Key references TipoMovimiento(Id),
	HoraInicio time not null,
	HoraFinal time not null,
	CantidadMinutos int not null,
	Activo int not null
);