USE [Empresa]

-- Preparacion de XML -----------------
DECLARE @XMLData XML
DECLARE @hdoc int
SET NOCOUNT ON

SELECT @XMLData = C
FROM OPENROWSET (BULK 'C:\ProyectoBases\XML\configuracionTarifas.xml',SINGLE_BLOB) AS Operaciones(C)
EXEC sp_xml_preparedocument @hdoc OUTPUT,@XMLData

----------- TABLAS TEMPORALES -------------------
DECLARE @ElementoDeTipoTarifa TABLE (Id int not null identity(1,1), IdTipoTarifa int not null, IdTipoElemento int not null,Valor varchar(20) not null);




----------- Tipo Relacion Familiar -------------------
INSERT INTO dbo.TipoRelacion(Id,Nombre,Activo)
SELECT Id1,Nombre1,1
FROM OPENXML (@hdoc, '/configTarifas/TipoRelacionFamiliar',1)
	WITH ( 
		Id1 int '@ID', Nombre1 varchar(50) '@Nombre'
	);

---------- Tipo Tarifas/TipoContrato -------------------
/*
	1. Personal
	2. 800
	3. 900
*/
INSERT INTO dbo.TipoContrato(Id,Nombre,TipoTelefono,Activo)
SELECT Id1,Nombre1,CASE WHEN Nombre1 LIKE '%900%' then 3
						WHEN Nombre1 LIKE '%800%' then 2 else 1 end
						,1
FROM OPENXML (@hdoc, '/configTarifas/TipoTarifa',1)
	WITH ( 
		Id1 int '@ID', Nombre1 varchar(50) '@Nombre'
	);

---------- Tipo Elemento/ConceptoTarifa -------------------------
INSERT INTO dbo.ConceptoTarifa(Id,Nombre,Unidad,Activo)
SELECT Id1,Nombre1,TipoValor,1
FROM OPENXML (@hdoc, '/configTarifas/TipoElemento',1)
	WITH ( 
		Id1 int '@ID', Nombre1 varchar(100) '@Nombre',TipoValor varchar(30) '@TipoValor'
	);

---------- ElementoDeTipoTarifa/TipoContratoXConceptoTarifa --------------------------------------------------------------------------
INSERT INTO dbo.TipoContratoXConceptoTarifa(IdTipoContrato,IdConceptoTarifa,Valor,Activo)
SELECT IdTipoTarifa1,IdTipoElemento1,Valor1,1
FROM OPENXML (@hdoc, '/configTarifas/ElementoDeTipoTarifa',1)
	WITH ( 
		IdTipoTarifa1 int '@IDTipoTarifa', IdTipoElemento1 int '@IDTipoElemento',Valor1 real '@Valor'
	);


					--------------------- ESPECIALIZACIONES ------------------------

---  En este estan los que tienen un valor Integer como cantidad de minutos y cantidad de megas
INSERT INTO dbo.MontoMinutoFijo(Id,Activo)
SELECT TC.Id,1
FROM dbo.TipoContratoXConceptoTarifa TC inner join dbo.ConceptoTarifa C on TC.IdConceptoTarifa = C.Id 
									   inner join dbo.TipoContrato T on TC.IdTipoContrato = T.Id
WHERE C.Unidad = 'Integer';

------ Todos los que se relacionan con un costo fijo por minutos ---------------
INSERT INTO dbo.MontoDineroFijo(Id,Activo)
SELECT TC.Id,1
FROM dbo.TipoContratoXConceptoTarifa TC inner join dbo.ConceptoTarifa C on TC.IdConceptoTarifa = C.Id 
									   inner join dbo.TipoContrato T on TC.IdTipoContrato = T.Id
WHERE C.Unidad = 'Valor Monetario Fijo';

------ Todos los que se relacionan con un costo porcentual, en este caso IVA ---------------
INSERT INTO dbo.MontoDineroPorcentaje(Id,Activo)
SELECT TC.Id,1
FROM dbo.TipoContratoXConceptoTarifa TC inner join dbo.ConceptoTarifa C on TC.IdConceptoTarifa = C.Id 
									    inner join dbo.TipoContrato T on TC.IdTipoContrato = T.Id
WHERE C.Unidad = 'Valor Monetario Porcentual';

------ Todos los que se relacionan con un costo fijo por megas ---------------
INSERT INTO dbo.MontoMegaFijo(Id,Activo)
SELECT TC.Id,1
FROM dbo.TipoContratoXConceptoTarifa TC inner join dbo.ConceptoTarifa C on TC.IdConceptoTarifa = C.Id 
									    inner join dbo.TipoContrato T on TC.IdTipoContrato = T.Id
WHERE C.Unidad = 'Valor Mega Fijo';

-------------------------------------------------------------------------------------------------------------------------------------------------

----------- Tipos de Movimiento -------------------------------------
INSERT INTO dbo.TipoMovimiento(Id,Nombre,Activo) values (1,'Credito',1),(2,'Debito',1);


----------- Empresa Externa ----------------------------------
INSERT INTO dbo.EmpresaExterna (Nombre,Activo) values ('Empresa X',1),('Empresa Y',1);


EXEC sp_xml_removedocument @hdoc;