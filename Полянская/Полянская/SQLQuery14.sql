CREATE DATABASE BD;
GO

USE BD;
GO


CREATE TABLE Users (
    Username NVARCHAR(50) NOT NULL,
    Password NVARCHAR(50) NOT NULL
);
GO

--Цикл для создания пользователей, баз данных и настройки прав доступа
CREATE PROCEDURE CreateUsersAndDatabases
AS
BEGIN
    DECLARE @i INT = 1;
    DECLARE @username NVARCHAR(50);
    DECLARE @password NVARCHAR(50);
    DECLARE @dbname NVARCHAR(50);
    DECLARE @sql NVARCHAR(MAX);

    WHILE @i <= 10
    BEGIN
        SET @username = 'user' + CAST(@i AS NVARCHAR(50));
        SET @password = (
            SELECT SUBSTRING(CONVERT(VARCHAR(40), NEWID()), 0, 4) +
                   SUBSTRING(CONVERT(VARCHAR(40), NEWID()), 0, 3)
        );
        SET @dbname = 'BD' + CAST(@i AS NVARCHAR(50));

        -- Создание логина и пользователя
        SET @sql = 'CREATE LOGIN ' + @username + ' WITH PASSWORD = ''' + @password + ''';';
        EXEC sp_executesql @sql;

        -- 
        SET @sql = 'CREATE DATABASE ' + @dbname + ';';
        EXEC sp_executesql @sql;

        --
        SET @sql = 'USE ' + @dbname + '; CREATE USER ' + @username + ' FOR LOGIN ' + @username + ';';
        EXEC sp_executesql @sql;

        -- 
        SET @sql = 'USE ' + @dbname + '; ALTER ROLE db_owner ADD MEMBER ' + @username + ';';
        EXEC sp_executesql @sql;

        -- 
        INSERT INTO Users (Username, Password) VALUES (@username, @password);

        SET @i = @i + 1;
    END
END
GO

-- 
EXEC CreateUsersAndDatabases;
GO



CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'StrongMasterKeyPassword!';
GO

-- 
CREATE CERTIFICATE PasswordCert
    WITH SUBJECT = 'Password Encryption Certificate';
GO

-- 
CREATE SYMMETRIC KEY PasswordKey
    WITH ALGORITHM = AES_256
    ENCRYPTION BY CERTIFICATE PasswordCert;
GO

-- открытие ключа
OPEN SYMMETRIC KEY PasswordKey
    DECRYPTION BY CERTIFICATE PasswordCert;

UPDATE Users
SET Password = ENCRYPTBYKEY(KEY_GUID('PasswordKey'), Password);
GO
--шифрование
CLOSE SYMMETRIC KEY PasswordKey;
GO
select * from Users


USE BD;
GO

-- сертификат
OPEN SYMMETRIC KEY PasswordKey
    DECRYPTION BY CERTIFICATE PasswordCert;
GO

-- вывод таблицы с логином и паролем
SELECT 
    Username,
    CAST(DECRYPTBYKEY(Password) AS NVARCHAR(MAX)) AS DecryptedPassword
FROM Users;
GO

-- бэкап
CLOSE SYMMETRIC KEY PasswordKey;
GO

BACKUP DATABASE BD
TO DISK = 'C:\BD.bak'
WITH FORMAT,
MEDIANAME = 'SQLServerBackups',
NAME = 'Full Backup of BD';
GO

RESTORE DATABASE BD
FROM DISK = 'C:\BD.bak'
WITH REPLACE;
GO






DROP PROCEDURE CreateUsersAndDatabases;

use master 
drop database BD
drop database BD1
drop database BD2
drop database BD3
drop database BD4
drop database BD5
drop database BD6
drop database BD7
drop database BD8
drop database BD9
drop database BD10


drop login user1
drop login user2
drop login user3
drop login user4
drop login user5
drop login user6
drop login user7
drop login user8
drop login user9
drop login user10