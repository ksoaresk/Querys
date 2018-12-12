IF OBJECT_ID('dbo.user_online', 'U') IS NOT NULL
	DROP TABLE dbo.user_online
	
CREATE TABLE dbo.user_online(	
	cod_user INT NOT NULL,
	cod_empresa INT NOT NULL,
	data_acesso DATETIME NOT NULL DEFAULT GETDATE(),
	latitude VARCHAR(64),
	longitude VARCHAR(64),
	ip VARCHAR(20),
	PRIMARY KEY(cod_user, cod_empresa),
	FOREIGN KEY(cod_user) REFERENCES usuario(cod_user),
	FOREIGN KEY(cod_empresa) REFERENCES empresa_gestora(cod_empresa)
)

IF OBJECT_ID('dbo.GERAR_INF_USER_OLINE', 'P') IS NOT NULL  
    DROP PROCEDURE dbo.GERAR_INF_USER_OLINE

CREATE PROCEDURE dbo.GERAR_INF_USER_OLINE @codUser INT,
										  @codEmpresa INT,
										  @lat VARCHAR(64) = NULL,
										  @longt VARCHAR(64) = NULL,
										  @ip VARCHAR(20) = NULL
--WITH ENCRYPT
AS
BEGIN
	-- INSERE O REGISTRO DO USUÁRIO CASO O MESMO AINDA NÃO ESTEJA NA LISTA.
	-- O CAMPO DATETIME SERÁ GERADO AUTOMATICAMENTE PELA ESTRUTURA DA TABELA
	IF(NOT EXISTS( SELECT
						 TOP 1 1
						FROM user_online
						WHERE cod_empresa = @codEmpresa 
							  AND cod_user = @codUser))
	BEGIN
		INSERT INTO user_online(cod_user, cod_empresa, latitude, longitude, ip) VALUES(@codUser, @codEmpresa, @lat, @longt, @ip)		
	END
	ELSE
	BEGIN
		UPDATE user_online SET data_acesso = GETDATE() WHERE cod_user = @codUser AND cod_empresa = @codEmpresa
	END
	
	
	IF(@@ERROR <> 0)
		RAISERROR('01. GERAR_INF_USER_ONLINE: NÃO É POSSÍVEL ATUALIZAR STATUS DE USUÁRIO ON-LINE!', 16,1)
		
		
	-- DELETA INFORMAÇÕES DO USUÁRIO QUE NÃO ESTIVER ATUALIZADO DADOS NA TABELA USER_ONLINE NO PRAZO DE 60SEGUNDOS 
	DELETE FROM user_online WHERE data_acesso < DATEADD(SECOND, -60, GETDATE())
	IF(@@ERROR <> 0)
		RAISERROR('02. GERAR_INF_USER_ONLINE: NÃO É POSSÍVEL ATUALIZAR STATUS DE USUÁRIO ON-LINE!', 16,1)
		
END