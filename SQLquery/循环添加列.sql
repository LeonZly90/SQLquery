CREATE TABLE Assignment ([fruit] NVARCHAR(20), [value] INT NOT NULL);

INSERT INTO Assignment VALUES (7);
INSERT INTO Assignment VALUES (3);
INSERT INTO Assignment VALUES (8);
INSERT INTO Assignment VALUES (4);

DECLARE @maxV INT, @i INT;
DECLARE @fieldName NVARCHAR(20);
DECLARE @alterSql NVARCHAR(256);

SET @maxV = (SELECT MAX([value]) FROM Assignment);

SET @i = 1;
WHILE @i <= @maxV
BEGIN
	SET @fieldName = 'new' + CAST(@i AS NVARCHAR(20));
	SET @alterSql = 'ALTER TABLE Assignment ADD '+@fieldName+' INT';
	EXEC(@alterSql);
	SET @i += 1;
END
---------------------------------------------------------------------------
--select * from Assignment
--drop table Assignment
---------------------------------------------------------------------------
DECLARE @V_Tuple AS INT;
--DECLARE @fieldName NVARCHAR(20);
DECLARE @updateSql NVARCHAR(256);
DECLARE @V_RT AS INT;

-- 声明游标
DECLARE C_Assignment CURSOR FAST_FORWARD FOR
    SELECT [value] FROM Assignment
    
OPEN C_Assignment;

FETCH NEXT FROM C_Assignment INTO @V_Tuple;

WHILE @@FETCH_STATUS=0
BEGIN
	SET @V_RT = 1;
	WHILE @V_RT <= @V_Tuple
	BEGIN
		SET @fieldName = 'new' + CAST(@V_RT AS NVARCHAR(20));
		SET @updateSql = 'UPDATE Assignment SET '+@fieldName+' = ' + CAST(@V_RT AS NVARCHAR(20)) + ' WHERE [value] = ' + CAST(@V_Tuple AS NVARCHAR(20)) + '';
		EXEC(@updateSql);
		SET @V_RT += 1;
	END

    FETCH NEXT FROM C_Assignment INTO @V_Tuple;
END

CLOSE C_Assignment;
DEALLOCATE C_Assignment;