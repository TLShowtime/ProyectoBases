USE [Empresa]

-- Nodo <ClienteNuevo> 
CREATE TYPE ClienteNuevo AS TABLE (id INT IDENTITY(1,1) not null, Nombre varchar(100) not null,Identificacion varchar(10) not null);

-- Nodo <NuevoContrato>
CREATE TYPE NuevoContrato AS TABLE (id INT IDENTITY(1,1) not null,Identificacion varchar(10) not null,Numero varchar(20) not null, TipoTarifa int not null);

-- Nodo <RelacionFamiliar>
CREATE TYPE RelacionFamiliar AS TABLE (id INT IDENTITY(1,1) not null,IdentificacionDe varchar(10) not null,IdentificacionA varchar(10) not null,TipoRelacion int not null);
