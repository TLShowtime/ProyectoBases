USE [Empresa]

-- Nodo <ClienteNuevo> 
CREATE TYPE ClienteNuevo AS TABLE (id INT IDENTITY(1,1) not null, Nombre varchar(100) not null,Identificacion varchar(10) not null);

-- Nodo <NuevoContrato>
CREATE TYPE NuevoContrato AS TABLE (id INT IDENTITY(1,1) not null,Identificacion varchar(10) not null,Numero varchar(20) not null, TipoTarifa int not null);

-- Nodo <RelacionFamiliar>
CREATE TYPE RelacionFamiliar AS TABLE (id INT IDENTITY(1,1) not null,IdentificacionDe varchar(10) not null,IdentificacionA varchar(10) not null,TipoRelacion int not null);

-- <LlamadaTelefonica NumeroDe="85558939" NumeroA="85551324" Inicio="17:47" Fin="19:59"/>
CREATE TYPE LlamadaTelefonica AS TABLE (id INT IDENTITY(1,1) not null, NumeroDe varchar(20) not null, NumeroA varchar(20),Inicio time not null,Fin time not null);

-- <UsoDatos Numero="65558743" CantMegas="39.03"/>
CREATE TYPE UsoDatos AS TABLE (id INT IDENTITY(1,1) not null,Numero varchar(20) not null, CantidadMegas real not null);

-- <PagoFactura Numero=h87554620h>
CREATE TYPE PagoFactura AS TABLE (id INT IDENTITY(1,1) not null, Numero varchar(20) not null);