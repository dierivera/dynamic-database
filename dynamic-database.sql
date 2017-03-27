CREATE DATABASE ProyectoDB
USE ProyectoDB

/*Ejecutar para resolver problemas de quotes*/
SET QUOTED_IDENTIFIER ON

CREATE TABLE Usuario
(
id int IDENTITY PRIMARY KEY,
UserName varchar(20) NOT NULL,
Passwrd varchar(20) NOT NULL
)
INSERT INTO Usuario VALUES ('user','pass');

DROP TABLE Tokens
CREATE TABLE Tokens
(
id int IDENTITY PRIMARY KEY,
token varchar(20) 
)

/*CREATE TABLE Imagen
(
id int IDENTITY PRIMARY KEY,
ruta varchar(20),
fotografia image
)*/

CREATE TABLE Categoria
(
id int IDENTITY PRIMARY KEY,
Nombre NVARCHAR(50)
)

select * from Usuario;
/*RANDOM*/   /*select substring(replace(newid(), '-', ''), 1, 8)*/

----------------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------PROCEDIMIENTO QUE CREA TABLAS------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------
---------EJEMPLO: EXEC insertTable 'JuegoComedor', 'varchar(20),varchar(20),varchar(20),int','Nombre,Madera,Color,NoSillas';------------
ALTER  PROCEDURE SP_CREATE_TABLE 
@P_CATALOG  NVARCHAR(200),  
@P_SCHEMA  NVARCHAR(50),  
@P_TABLE_NAME  NVARCHAR(50),  
@P_TIPOS  NVARCHAR(100), 
@P_COLUMNS  NVARCHAR(100),  
@P_STATUS  NVARCHAR(1) OUTPUT,  
@P_TEXT   NVARCHAR(240) OUTPUT  
AS  
  
BEGIN  
    DECLARE  
	---el tmp script va a guardar el script que se ejecutara luego de construirse
    @TMP_CREATE_TABLE_SCRIPT NVARCHAR(MAX),  
	@TMP_COLUMN_TYPE      NVARCHAR(100),
    @TMP_COLUMN_NAME      NVARCHAR(100)  
    
    SET @TMP_COLUMN_NAME = ''  
    SET @TMP_CREATE_TABLE_SCRIPT = ''  
      
    BEGIN TRY  
      IF (NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES     
     WHERE TABLE_CATALOG = @P_CATALOG   
     AND TABLE_SCHEMA = @P_SCHEMA  
      AND TABLE_NAME = @P_TABLE_NAME))  
      BEGIN  
	  ---almacenaran los valores ingresados en un string! guardan cada uno en una fila de la tabla
	  --- en dos tablas, una para los tipos y otro para los 
 DECLARE @T_COLUMNTABLE TABLE  
 (T_PKEY       INT IDENTITY(1,1),  
  T_COLUMNNAME NVARCHAR(MAX))  

  DECLARE @T_TIPOSTABLE TABLE  
 (T_PKEY       INT IDENTITY(1,1),  
  T_COLUMNNAME NVARCHAR(MAX))  
       ---los inserta en las tablas antes mencionadas
 INSERT INTO @T_COLUMNTABLE   
 SELECT ITEMS FROM DBO.SPLIT(@P_COLUMNS,',')  
       
        SELECT * FROM @T_COLUMNTABLE  
		---los inserta en las tablas antes mencionadas
INSERT INTO @T_TIPOSTABLE   
 SELECT ITEMS FROM DBO.SPLIT(@P_TIPOS,',')  
       
        SELECT * FROM @T_TIPOSTABLE  
       ---hace un loop por la cantidad de filas de las tablas y los ingresa en el string
 DECLARE @ITEM_COUNTER INT  
 DECLARE @LOOP_COUNTER INT  
 DECLARE @TMP_COUNT INT  
      
 SET @TMP_COUNT = 0  
 SET @LOOP_COUNTER =   
            ISNULL((SELECT COUNT(*) FROM @T_COLUMNTABLE),0)  
 SET @ITEM_COUNTER = 1  
		--- se inicia el string con la tabla a usar y la base de datos
 SET @TMP_CREATE_TABLE_SCRIPT =   
             'USE ' + @P_CATALOG + '; CREATE TABLE ' +    
             @P_TABLE_NAME + ' ' +  
      '(id INT IDENTITY(1,1) PRIMARY KEY, imagen NVARCHAR(500), '   
      --- se le inserta los entradas por default, el id y la imagen (todos lo tendran)
 WHILE @LOOP_COUNTER > 0 AND @ITEM_COUNTER <= @LOOP_COUNTER  
 BEGIN  
   SELECT @TMP_COLUMN_NAME = T_COLUMNNAME  
     FROM @T_COLUMNTABLE  
   WHERE T_PKEY  = @ITEM_COUNTER  
   SELECT @TMP_COLUMN_TYPE = T_COLUMNNAME  
     FROM @T_TIPOSTABLE  
   WHERE T_PKEY  = @ITEM_COUNTER  
        ---separa entre cada entry
   IF (@TMP_COUNT <> 0)  
   BEGIN  
     SET @TMP_CREATE_TABLE_SCRIPT =   
                       @TMP_CREATE_TABLE_SCRIPT + ','  
   END  
       ---hace que no sean nulos para que todos se deban de recibir
   SET @TMP_CREATE_TABLE_SCRIPT =   
             @TMP_CREATE_TABLE_SCRIPT + @TMP_COLUMN_NAME +   ' ' +
                                       @TMP_COLUMN_TYPE + ' NOT NULL' 
   SET @TMP_COUNT = @TMP_COUNT + 1  
   SET @ITEM_COUNTER = @ITEM_COUNTER + 1  
 END  
      
 SET @TMP_CREATE_TABLE_SCRIPT = @TMP_CREATE_TABLE_SCRIPT +')'  
 EXEC dbo.sp_executesql @TMP_CREATE_TABLE_SCRIPT  
 SELECT @TMP_CREATE_TABLE_SCRIPT  
	---pone una Y en status si hay exito      
 SET @P_STATUS = 'Y'  
 SET @P_TEXT   = 'Tabla Creada, Exito'  

      END  
      ELSE  
      BEGIN  
 SET @P_STATUS = 'N'  
 SET @P_TEXT   = 'Tabla existente'  
      END  
  
    END TRY  
    BEGIN CATCH    
      IF @@TRANCOUNT > 0  
	  -- levanta un error con los detalles de la excepcion 
      DECLARE @ErrMsg nvarchar(4000), @ErrSeverity int, @ErrLine int  
      SELECT @ErrMsg = ERROR_MESSAGE(),  
                @ErrSeverity = ERROR_SEVERITY(),  
  @ErrLine = ERROR_LINE()   
  
      SET @P_STATUS = 'N'  
      SET @P_TEXT  = 'Error al crear tabla'  
      RAISERROR(@ErrMsg, @ErrSeverity, 1)  
    END CATCH  
    --SELECT * FROM @T_COLUMNTABLE  
END    

----------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------Funcion que hace split para la lectura de columnas-------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

CREATE FUNCTION [DBO].[SPLIT]  
(  
 @STRING NVARCHAR(4000),   
 @DELIMITER CHAR(1)  
)  
RETURNS   
 @RESULTS TABLE (T_PKEY INT IDENTITY(1,1) NOT NULL,ITEMS NVARCHAR(MAX))  
AS  
BEGIN  
  DECLARE @INDEX INT  
  DECLARE @SLICE NVARCHAR(4000)  
  
  SELECT @INDEX = 1  
  IF @STRING IS NULL RETURN  
  
  WHILE @INDEX != 0  
  BEGIN  
    SELECT @INDEX = CHARINDEX(@DELIMITER,@STRING)  
    IF @INDEX !=0  
      SELECT @SLICE = LEFT(@STRING,@INDEX - 1)  
    ELSE  
      SELECT @SLICE = @STRING  
  
    INSERT INTO @RESULTS(ITEMS) VALUES(@SLICE)  
    SELECT @STRING = RIGHT(@STRING,LEN(@STRING) - @INDEX)  
    IF LEN(@STRING) = 0 BREAK  
  END RETURN  
END  


----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- Update Dinamico ------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

DROP PROCEDURE SP_ALTER_TABLE;
--- Procedimiento que se encarga de alterar las columnas de una fila!
CREATE  PROCEDURE SP_ALTER_TABLE 
@P_TABLE_NAME  NVARCHAR(50),  
@P_COLUMNS  NVARCHAR(500),  
@P_NewValor  NVARCHAR(500), 
@id_Selected NVARCHAR (3),
@Token VARCHAR(20) ---validacion de usuario
AS  BEGIN  
    DECLARE  
	@LevantaError VARCHAR (20),		
	@TokenExiste INT,
    @TMP_SCRIPT NVARCHAR(MAX),  
	@TMP_COLUMN_Valores     NVARCHAR(500),
    @TMP_COLUMN_NAME      NVARCHAR(500)  
    
	SET @LevantaError = 'Usuario no valido';
	---se valida si el usuario existe
			SET @TokenExiste = (select 1 from Tokens where token = @Token) 
			IF @TokenExiste IS NOT NULL
			BEGIN
    SET @TMP_SCRIPT = ''  
	---tablas temporales para almacenar los valores recibidos
 DECLARE @T_COLUMNTABLE TABLE  
 (T_PKEY       INT IDENTITY(1,1),  
  T_COLUMNNAME NVARCHAR(MAX)) 

  DECLARE @T_TIPOSTABLE TABLE  
 (T_PKEY       INT IDENTITY(1,1),  
  T_COLUMNNAME NVARCHAR(MAX))  
SET @TokenExiste = (select 1 from Tokens where token = @Token)
	IF @TokenExiste IS NOT NULL
	BEGIN
 INSERT INTO @T_COLUMNTABLE   
 ---separa los items del string y los mete en las tablas
 SELECT ITEMS FROM DBO.SPLIT(@P_COLUMNS,',')  
       
        SELECT * FROM @T_COLUMNTABLE  

INSERT INTO @T_TIPOSTABLE   
 SELECT ITEMS FROM DBO.SPLIT(@P_NewValor,',')  
       
        SELECT * FROM @T_TIPOSTABLE  
       
 DECLARE @ITEM_COUNTER INT  
 DECLARE @LOOP_COUNTER INT  
 DECLARE @TMP_COUNT INT  
      
 SET @TMP_COUNT = 0  
 SET @LOOP_COUNTER =   
            ISNULL((SELECT COUNT(*) FROM @T_COLUMNTABLE),0)  
 SET @ITEM_COUNTER = 1  
      ---mismo procedimiento que crear tablas pero hace un simple update de la tabla elegida y setea los valores recibidos.
 SET @TMP_SCRIPT =   
             'UPDATE ' +    
             @P_TABLE_NAME + ' SET ' 
      
 WHILE @LOOP_COUNTER > 0 AND @ITEM_COUNTER <= @LOOP_COUNTER  
 BEGIN  
   SELECT @TMP_COLUMN_NAME = T_COLUMNNAME  
     FROM @T_COLUMNTABLE  
   WHERE T_PKEY  = @ITEM_COUNTER  
   SELECT @TMP_COLUMN_Valores = T_COLUMNNAME  
     FROM @T_TIPOSTABLE  
   WHERE T_PKEY  = @ITEM_COUNTER  
    IF (@TMP_COUNT <> 0)  
   BEGIN  
     SET @TMP_SCRIPT =   @TMP_SCRIPT + ','  
   END  
   ---recibe el valor y lo iguala a su nuevo valor para sobreescribirlo.
   SET @TMP_SCRIPT =   
             @TMP_SCRIPT + @TMP_COLUMN_NAME +   ' = ' +
                                       @TMP_COLUMN_Valores 
   SET @TMP_COUNT = @TMP_COUNT + 1  
   SET @ITEM_COUNTER = @ITEM_COUNTER + 1  
 END  
      
 SET @TMP_SCRIPT = @TMP_SCRIPT +' WHERE id = ' + @id_Selected
 EXEC dbo.sp_executesql @TMP_SCRIPT  
 SELECT @TMP_SCRIPT  
    END /*CIERRA EL IF DE SI USUARIO EXISTE O NO*/ 
	END
	ELSE
		SELECT @LevantaError ---si no existe levanta este error
END    

/*Ejemplo de ejecucion*/
EXEC SP_ALTER_TABLE 'Refrigeradora',  "marca,imagen","'Diego','http://files.parsetfss.com/e6066302-0fcc-4a86-8709-bbefa3d4cbea/tfss-6bcef4e8-68f7-407f-a413-1d086510a3b5-myfile.txt'", '1','4D40B8F68B1D41E'


----------------------------------------------------------------------------------------------------------------------------------------
------------------------------------------------------- Busqueda -----------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

DROP PROCEDURE SP_SEARCH
CREATE  PROCEDURE SP_SEARCH
@P_TABLE_NAME  NVARCHAR(50),  
@P_COLUMNS  NVARCHAR(100),  
@P_NewValor  NVARCHAR(100)
AS  BEGIN  
    DECLARE  
    @TMP_SCRIPT NVARCHAR(MAX),  
	@TMP_COLUMN_Valores     NVARCHAR(100),
    @TMP_COLUMN_NAME      NVARCHAR(100)  
    
    SET @TMP_SCRIPT = ''  
	---tablas temporales para almacenar los valores
 DECLARE @T_COLUMNTABLE TABLE  
 (T_PKEY       INT IDENTITY(1,1),  
  T_COLUMNNAME NVARCHAR(MAX)) 

  DECLARE @T_TIPOSTABLE TABLE  
 (T_PKEY       INT IDENTITY(1,1),  
  T_COLUMNNAME NVARCHAR(MAX))  
       ---ingresa los items en las tablas
 INSERT INTO @T_COLUMNTABLE   
 SELECT ITEMS FROM DBO.SPLIT(@P_COLUMNS,',')  
       
        SELECT * FROM @T_COLUMNTABLE  

INSERT INTO @T_TIPOSTABLE   
 SELECT ITEMS FROM DBO.SPLIT(@P_NewValor,',')  
       
        SELECT * FROM @T_TIPOSTABLE  
       
 DECLARE @ITEM_COUNTER INT  
 DECLARE @LOOP_COUNTER INT  
 DECLARE @TMP_COUNT INT  
      
 SET @TMP_COUNT = 0  
 SET @LOOP_COUNTER =   
            ISNULL((SELECT COUNT(*) FROM @T_COLUMNTABLE),0)  
 SET @ITEM_COUNTER = 1  
      ---genera el script a ejecutar al final
 SET @TMP_SCRIPT =   
             'SELECT id FROM ' +    
             @P_TABLE_NAME + ' WHERE ' 
      
 WHILE @LOOP_COUNTER > 0 AND @ITEM_COUNTER <= @LOOP_COUNTER  
 BEGIN  
   SELECT @TMP_COLUMN_NAME = T_COLUMNNAME  
     FROM @T_COLUMNTABLE  
   WHERE T_PKEY  = @ITEM_COUNTER  
   SELECT @TMP_COLUMN_Valores = T_COLUMNNAME  
     FROM @T_TIPOSTABLE  
   WHERE T_PKEY  = @ITEM_COUNTER  
    IF (@TMP_COUNT <> 0)  
   BEGIN  
     SET @TMP_SCRIPT =   @TMP_SCRIPT + ' AND '  
   END  
   
   SET @TMP_SCRIPT =   
             @TMP_SCRIPT + @TMP_COLUMN_NAME +   ' LIKE ' + CHAR(39) + '%' +
                                       @TMP_COLUMN_Valores + '%' + CHAR(39)
   SET @TMP_COUNT = @TMP_COUNT + 1  
   SET @ITEM_COUNTER = @ITEM_COUNTER + 1  
 END  
 EXEC dbo.sp_executesql @TMP_SCRIPT  
    
END    

--- busca filas que cumplan con los criterios de busqueda
EXEC SP_SEARCH 'cocina',  "marca, color","at,ri";

---- Hace lo mismo que el stored procedure
/*SELECT * FROM cocina WHERE marca LIKE '%at%' and color like '%ri%';*/

----------------------------------------------------------------------------------------------------------------------------------------
----------------------------------------------------- Procedimientos -------------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------------------------

DROP PROCEDURE Login
-- Procedimiento que hace el login, genera un token aleatorio
CREATE PROCEDURE Login
	@User Varchar(50),
	@Passwrd varchar(50)
	AS BEGIN
		DECLARE @Token Varchar(20);
		DECLARE @Existe varchar(10);
		---revisa si existe el usuario
		SET @Existe = (SELECT count(*) FROM Usuario WHERE UserName = @User AND Passwrd = @Passwrd)
		--- generacion de token aleatorio en Hex de 15 caracteres
		SELECT @Token = substring(replace(newid(), '-', ''), 1, 15)  ;
		IF (@Existe = 1)
			BEGIN
				INSERT INTO Tokens VALUES (@Token); ---lo ingresa en la tabla para revisar si existe el user y este se loggeo
				SELECT @Token;
			END
		ELSE
			SELECT @Existe;
	END

---  Prueba del stored procedure de login de usuario, contrasena
EXEC Login 'user', 'pass';


DROP PROCEDURE creaUser
-- Procedimiento que hace el login, genera un token aleatorio
CREATE PROCEDURE creaUser
	@User Varchar(50),
	@Passwrd varchar(50),
	@Token varchar(20)
	AS BEGIN
		DECLARE @LevantaError VARCHAR (20);
		DECLARE @Existe varchar(10);
		SET @LevantaError = 'Token no valido';
		SET @Existe = (SELECT count(*) FROM Tokens WHERE Token = @Token)
		IF (@Existe = 1)
			BEGIN
			INSERT INTO Usuario VALUES (@User, @Passwrd); ---lo ingresa en la tabla para revisar si existe el user y este se loggeo
			END
		ELSE
		SELECT @LevantaError;
	END

select * from tokens;
select * from Usuario;
EXEC CreaUser 'Diego','contra','6F6FDEEF11FB4ED';


DROP PROCEDURE insertTable
/*Procedimiento que genera una nueva tabla de manera dinamica! */
CREATE PROCEDURE insertTable
	@NombreTabla NVARCHAR(50),
	@Tipos NVARCHAR (100),	
	@Columnas NVARCHAR (100),
	@Token VARCHAR(20)
	AS BEGIN 
		DECLARE 
		@LevantaError VARCHAR (20),		
		@TokenExiste INT,
		@TMP_INSERT_INTO_TABLE_SCRIPT NVARCHAR(MAX),
		@P_STATUS  NVARCHAR(1),  
		@P_TEXT   NVARCHAR(240) 
			SET @LevantaError = 'Usuario no valido';
			SET @TokenExiste = (select id from Tokens where token = @Token) ---se valida el token para revisar el user
			IF @TokenExiste IS NOT NULL
			BEGIN
			EXEC SP_CREATE_TABLE 'ProyectoDB',  
                   'dbo',  
                   @NombreTabla, 
				   @Tipos, 
                   @Columnas,  
                   @P_STATUS out,  
                   @P_TEXT out  
				   ---se reciben los valores del stored procedure y se revisa si fue exitoso o no
		SELECT @P_STATUS,@P_TEXT  
		IF @P_STATUS='Y'
			INSERT INTO dbo.Categoria(Nombre) VALUES (@NombreTabla)
			END
			ELSE
				SELECT @LevantaError ---user no existe, se devuelve el error.
	END

-- Declaracion que se encarga de insertar las tablas en la base de datos (tiene validacion de token)
EXEC insertTable 'Radiador', 'int,int,NVARCHAR(100),int,int,int','Aleta,Colector,Lateral,Tanque,Enfriador,TipoColmena','6F6FDEEF11FB4ED';
EXEC insertTable 'Cocina', 'int,NVARCHAR(100)','Marca,discos','6F6FDEEF11FB4ED';

DROP PROCEDURE getColumns;
-- Procedimiento que hace get de las columnas de X tabla
CREATE PROCEDURE getColumns
	@TableName Varchar(50)
	AS BEGIN 
		SELECT COLUMN_NAME, DATA_TYPE
		FROM information_schema.columns ---selecciona la tabla del esquema actual
		WHERE table_name = @TableName ---revisa que sea la tabla deseada.
		ORDER BY ordinal_position
	END

EXEC getColumns 'Radiador';


	
DROP PROCEDURE devuelveProducto;
-- Procedimiento que devuelve los productos de la tabla deseada
CREATE PROCEDURE devuelveProducto
	@TableName Varchar(50)
	AS BEGIN 
		DECLARE
			@TMP_SCRIPT NVARCHAR(MAX) 
			SET @TMP_SCRIPT = 'SELECT * FROM ' + @TableName  ---scriot generado 
			EXEC dbo.sp_executesql @TMP_SCRIPT   --- ejecucion del script
	END;


DROP PROCEDURE devuelveIdProductos;
/*Procedimiento que devuelve todos los id de productos de la tabla deseada*/
CREATE PROCEDURE devuelveIdProductos
	@TableName Varchar(50)
	AS BEGIN 
		DECLARE
			@TMP_SCRIPT NVARCHAR(MAX) 
			SET @TMP_SCRIPT = 'SELECT id FROM ' + @TableName ---scriot generado 
			EXEC dbo.sp_executesql @TMP_SCRIPT  --- ejecucion del script
	END;


DROP PROCEDURE devuelveProductoUnico;
/*Procedimiento que devuelve un producto de la tabla deseada, por id*/
CREATE PROCEDURE devuelveProductoUnico
	@TableName Varchar(50),
	@idProducto Varchar(2)
	AS BEGIN 
		DECLARE
			@TMP_SCRIPT NVARCHAR(MAX) --declara el script a ejecutar
			SET @TMP_SCRIPT = 'SELECT * FROM ' + @TableName + ' WHERE id=' + @idProducto ---scriot generado 
			EXEC dbo.sp_executesql @TMP_SCRIPT  --- ejecucion del script
	END;


DROP PROCEDURE actualizarProducto;
/*Actualiza una fila en una tabla (categoria)! recibe la tabla, los inputs a cambiar, los valores nuevos y el token de validacion*/
ALTER PROCEDURE actualizarProducto
	@IdFila Varchar(2), --fila a cambiar
	@TableName Varchar(50), --tabla donde se encuentra la fila
	@CampoCambiar nvarchar(500), --columnas deseadas de modificar
	@DatoActualizado nvarchar(500), --valores nuevos
	@Token VARCHAR(20)
	AS BEGIN 
		DECLARE
		@LevantaError VARCHAR (20),		
		@TokenExiste INT,
		@TMP_SCRIPT NVARCHAR(MAX) 
		SET @LevantaError = 'Usuario no valido';
		SET @TokenExiste = (select 1 from Tokens where token = @Token) --validacion de usuario
			IF @TokenExiste IS NOT NULL
			BEGIN 
				SET @TMP_SCRIPT = 'UPDATE ' + @TableName + ' Set ' + @CampoCambiar +' = ' + @DatoActualizado +' Where id=' + @IdFila + ';' --- script que actualiza un producto
				SELECT @TMP_SCRIPT
				/*EXEC dbo.sp_executesql @TMP_SCRIPT   --se ejecuta el query*/
			END
			ELSE
				SELECT @LevantaError
	END;
	
	/*Ejemplo de ejecucion*/
	SET QUOTED_IDENTIFIER ON
	EXEC actualizarProducto "1","Refrigeradora","imagen,dis","'HELP',4","6F6FDEEF11FB4ED";
	EXEC actualizarProducto "1","Refrigeradora","imagen","'http://files.parsetfss.com/e6066302-0fcc-4a86-8709-bbefa3d4cbea/tfss-85c95297-7b61-40bf-8647-909631e04441-myfile.txt'","6F6FDEEF11FB4ED";

	select * from Refrigeradora
	select * from tokens
DROP PROCEDURE insertRow;
/*Inserta una fila en una tabla (categoria) recibe la tabla, la url de la imagen, los inputs recibidos y el token de validacion*/
CREATE PROCEDURE insertRow
	@TableName Varchar(50),  
	@imagen varchar(129), --se recibe el url de la imagen
	@inputs Varchar(100),
	@Token VARCHAR(20)
	AS BEGIN 
		DECLARE
			@LevantaError VARCHAR (20),
			@TokenExiste INT,
			@TMP_SCRIPT NVARCHAR(MAX) 
			SET @LevantaError = 'Usuario no valido';
			SET @TokenExiste = (select 1 from Tokens where token = @Token) --validacion de usuario
			IF @TokenExiste IS NOT NULL
			BEGIN
				SET @TMP_SCRIPT = 'INSERT INTO ' + @TableName + ' VALUES (' + @imagen + ',' + @inputs + ')'  ---ingresa los valores a la tabla
				EXEC dbo.sp_executesql @TMP_SCRIPT  
			END
			ELSE
				SELECT @LevantaError	
	END;

	
	/*Ejemplo de ejecucion*/
	/*EXEC insertRow 'Crema', "'http://files.parsetfss.com/e6066302-0fcc-4a86-8709-bbefa3d4cbea/tfss-85c95297-7b61-40bf-8647-909631e04441-myfile.txt'", "'Pantene',100,'d'", '3352DC799EE0416'*/
	select * from tokens
	

-- Procedimiento que elimina un producto por id
ALTER PROCEDURE eliminarProductoUnico
	@TableName Varchar(50),
	@idProducto Varchar(2),
	@Token VARCHAR(20)
	AS BEGIN 
		DECLARE
			@LevantaError VARCHAR (20),	
			@TokenExiste INT,	
			@TMP_SCRIPT NVARCHAR(MAX) 

			SET @LevantaError = 'Usuario no valido'; --validacion de usuario
			SET @TokenExiste = (select 1 from Tokens where token = @Token)
			IF @TokenExiste IS NOT NULL
				BEGIN
				SET @TMP_SCRIPT = 'DELETE FROM ' + @TableName + ' WHERE id=' + @idProducto  ---query a ejecutar
				EXEC dbo.sp_executesql @TMP_SCRIPT   --ejecuta el query
			END
			ELSE
				SELECT @LevantaError
	END;

---Ejemplo de ejecucion del SP
EXEC devuelveProductoUnico 'Bielas',1


select * from tokens
delete from tokens where token = '51A551DCAC'

DROP PROCEDURE logOut
/*Procedimiento que genera una nueva tabla de manera dinamica! */
CREATE PROCEDURE logOut
	@Token VARCHAR(20)
	AS BEGIN 
		DELETE FROM tokens WHERE token = @Token ---se valida el token para revisar el user
	END
EXEC LOGOUT '97611924A2'