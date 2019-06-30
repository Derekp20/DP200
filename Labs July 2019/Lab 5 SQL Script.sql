CREATE MASTER KEY;
GO

CREATE DATABASE SCOPED CREDENTIAL AzureStorageCredential
WITH
IDENTITY = 'MOCID',
SECRET = 'QcJCJkJNiCvIy0YKqx8RzAJy05iHyd/CT4Oq1SzYAkgZ9UjsF92y9X6M8VeFpjq9cpP60eNBsEDxpEn3CXZjZg=='

CREATE EXTERNAL DATA SOURCE AzureStorage
WITH (
    TYPE = HADOOP,
    LOCATION = 'wasbs://data@awsadjp.blob.core.windows.net',
    CREDENTIAL = AzureStorageCredential
);

CREATE EXTERNAL FILE FORMAT TextFile
WITH (
    FORMAT_TYPE = DelimitedText,
    FORMAT_OPTIONS (FIELD_TERMINATOR = ',')
);

CREATE EXTERNAL TABLE dbo.DimDate2External (
[Date] datetime2(3) NULL,
[DateKey] decimal(38, 0) NULL,
[MonthKey] decimal(38, 0) NULL,
[Month] nvarchar(100) NULL,
[Quarter] nvarchar(100) NULL,
[Year] decimal(38, 0) NULL,
[Year-Quarter] nvarchar(100) NULL,
[Year-Month] nvarchar(100) NULL,
[Year-MonthKey] nvarchar(100) NULL,
[WeekDayKey] decimal(38, 0) NULL,
[WeekDay] nvarchar(100) NULL,
[Day Of Month] decimal(38, 0) NULL
)
WITH (
    LOCATION='/',
    DATA_SOURCE=AzureStorage,
    FILE_FORMAT=TextFile
);


SELECT * FROM dbo.DimDate2External;

CREATE TABLE dbo.Dates
WITH
(   
    CLUSTERED COLUMNSTORE INDEX,
    DISTRIBUTION = ROUND_ROBIN
)
AS
SELECT * FROM [dbo].[DimDate2External];

CREATE STATISTICS [DateKey] on [Dates] ([DateKey]);
CREATE STATISTICS [Quarter] on [Dates] ([Quarter]);
CREATE STATISTICS [Month] on [Dates] ([Month]);

SELECT * FROM dbo.Dates;
