IF OBJECT_ID('dbo.funcionario_online', 'U') IS NOT NULL
	DROP TABLE dbo.funcionario_online
	
CREATE TABLE dbo.funcionario_online(	
	cod_funcionario INT NOT NULL,
	cod_empresa INT NOT NULL,
	data_acesso DATETIME NOT NULL DEFAULT GETDATE(),
	latitude VARCHAR(64),
	longitude VARCHAR(64),
	ip VARCHAR(16),
	PRIMARY KEY(cod_funcionario, cod_empresa),
	FOREIGN KEY(cod_funcionario) REFERENCES funcionario(cod_funcionario)	
)

IF OBJECT_ID('dbo.GERAR_INF_FUNCIONARIO_OLINE', 'P') IS NOT NULL  
    DROP PROCEDURE dbo.GERAR_INF_FUNCIONARIO_OLINE

CREATE PROCEDURE dbo.GERAR_INF_FUNCIONARIO_OLINE @codFuncionario INT,
												 @codEmpresa INT,
												 @lat VARCHAR(64) = NULL,
												 @longt VARCHAR(64) = NULL,
												 @ip VARCHAR(64) = NULL
--WITH ENCRYPT
AS
BEGIN
	-- INSERE O REGISTRO DO USUÁRIO CASO O MESMO AINDA NÃO ESTEJA NA LISTA.
	-- O CAMPO DATETIME SERÁ GERADO AUTOMATICAMENTE PELA ESTRUTURA DA TABELA
	IF(NOT EXISTS( SELECT
						 TOP 1 1
						FROM funcionario_online
						WHERE cod_empresa = @codEmpresa 
							  AND cod_funcionario = @codFuncionario))
	BEGIN
		INSERT INTO funcionario_online(cod_funcionario, cod_empresa, latitude, longitude, ip) VALUES(@codFuncionario, @codEmpresa, @lat, @longt, @ip)		
	END
	ELSE
	BEGIN
		UPDATE funcionario_online SET data_acesso = GETDATE(), latitude = @lat, longitude = @longt, ip = @ip WHERE cod_funcionario = @codFuncionario AND cod_empresa = @codEmpresa
	END
	
	
	IF(@@ERROR <> 0)
		RAISERROR('01. GERAR_INF_USER_ONLINE: NÃO É POSSÍVEL ATUALIZAR STATUS DE USUÁRIO ON-LINE!', 16,1)
		
		
	-- DELETA INFORMAÇÕES DO USUÁRIO QUE NÃO ESTIVER ATUALIZADO DADOS NA TABELA FUNCIONÁRIO ON-LINE NO PRAZO DE 60SEGUNDOS 
	DELETE FROM funcionario_online WHERE data_acesso < DATEADD(SECOND, -60, GETDATE())
	IF(@@ERROR <> 0)
		RAISERROR('02. GERAR_INF_FUNCIONARIO_ONLINE: NÃO É POSSÍVEL ATUALIZAR STATUS DE USUÁRIO ON-LINE!', 16,1)
		
END