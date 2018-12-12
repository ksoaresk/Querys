IF OBJECT_ID('dbo.tipo_turno_trabalho', 'U') IS NOT NULL
	DROP TABLE dbo.tipo_turno_trabalho
	
CREATE TABLE dbo.tipo_turno_trabalho(
	cod_tipo INT NOT NULL IDENTITY(1,1)	,
	descricao VARCHAR(64) NOT NULL		,
	cod_empresa INT NOT NULL			,
	PRIMARY KEY(cod_tipo)
)

INSERT INTO tipo_turno_trabalho(descricao, cod_empresa) VALUES('SEMANAL', 5)
INSERT INTO tipo_turno_trabalho(descricao, cod_empresa) VALUES('12h/36h', 5)
INSERT INTO tipo_turno_trabalho(descricao, cod_empresa) VALUES('24h/72h', 5)
INSERT INTO tipo_turno_trabalho(descricao, cod_empresa) VALUES('5d/1d', 5)


IF OBJECT_ID('dbo.escala_trabalho_padrao', 'U') IS NOT NULL
	DROP TABLE dbo.escala_trabalho_padrao
CREATE TABLE dbo.escala_trabalho_padrao(
	cod_escala INT NOT NULL IDENTITY(1,1),
	cod_tipo INT NOT NULL				 ,
	p_entrada DATETIME NOT NULL			 , -- PRIMEIRA ENTRADA
	p_saida DATETIME NOT NULL			 , -- PRIMEIRA SAIDA
	s_entrada DATETIME NULL			 	 , -- SEGUNDA ENTRADA
	s_saida DATETIME NULL				 , -- SEGUNDA SAIDA
	dia INT NOT NULL					 , -- 0 = DOMING E 6 = SÁBADO
	virada_turno DATETIME NOT NULL		 ,
	limite_hr_extras DATETIME NOT NULL	 ,
	descricao VARCHAR(64) NULL			 ,
	PRIMARY KEY(cod_escala)				 ,
	FOREIGN KEY(cod_tipo) REFERENCES tipo_turno_trabalho(cod_tipo) ON DELETE CASCADE
)


IF OBJECT_ID('dbo.turno_trabalho', 'U') IS NOT NULL
	DROP TABLE dbo.turno_trabalho	
CREATE TABLE dbo.turno_trabalho(
	cod_turno INT NOT NULL IDENTITY(1,1)	 ,
	nro_interno INT NOT NULL				 ,
	cod_empresa INT NOT NULL				 ,
	cod_ccust INT NOT NULL					 ,
	cod_tipo_turno_trabalho INT NOT NULL	 ,
	descricao VARCHAR(64)					 ,
	ignorar_feriado BIT NOT NULL default 0	 , --NÃO IGNORAR FERIADO
	intervalo_pre_assinalado BIT NOT NULL default 0, 
	jornada_flexivel BIT NOT NULL DEFAULT 0  ,
	intervalo_flexivel BIT NOT NULL DEFAULT 0,
	PRIMARY KEY(cod_turno)					 ,
	FOREIGN KEY(nro_interno, cod_empresa) REFERENCES contratos(nro_interno, cod_empresa),
	FOREIGN KEY(cod_ccust) REFERENCES centro_custo(cod_ccust),
	FOREIGN KEY(cod_tipo_turno_trabalho) REFERENCES tipo_turno_trabalho(cod_tipo)
)

IF OBJECT_ID('dbo.escala_trabalho', 'U') IS NOT NULL
	DROP TABLE dbo.escala_trabalho
CREATE TABLE dbo.escala_trabalho(
	cod_escala INT NOT NULL IDENTITY(1,1),
	cod_turno INT NOT NULL				 ,
	p_entrada DATETIME NOT NULL			 , -- PRIMEIRA ENTRADA
	p_saida DATETIME NOT NULL			 , -- PRIMEIRA SAIDA
	s_entrada DATETIME NULL			 	 , -- SEGUNDA ENTRADA
	s_saida DATETIME NULL				 , -- SEGUNDA SAIDA
	dia INT NOT NULL					 , -- 0 = DOMING E 6 = SÁBADO
	virada_turno DATETIME NOT NULL		 ,
	limite_hr_extras DATETIME NOT NULL	 ,
	descricao VARCHAR(64) NOT NULL		 ,
	PRIMARY KEY(cod_escala)				 ,	
	FOREIGN KEY(cod_turno) REFERENCES turno_trabalho(cod_turno)
)

IF OBJECT_ID('dbo.marcacao_ponto', 'U') IS NOT NULL
	DROP TABLE dbo.marcacao_ponto
CREATE TABLE dbo.marcacao_ponto(
	cod_marcacao INT NOT NULL IDENTITY(1,1),
	cod_funcionario INT NOT NULL,
	hora_marcacao DATETIME DEFAULT GETDATE(),
	hora_ajustada DATETIME NULL,
	observacao_ajuste VARCHAR(100) NULL,
	endereco_marcacao VARCHAR(150) NULL,
	idr_ajustado BIT NOT NULL DEFAULT 0,
	idr_marcacao_manual BIT NOT NULL DEFAULT 0,
	hora_manual	DATETIME NULL,
	latitude VARCHAR(25),
	longitude VARCHAR(25),
	ip VARCHAR(16) NULL,
	dispositivo CHAR(1) NOT NULL,	
	PRIMARY KEY(cod_marcacao),
	CHECK(dispositivo = 'A' OR dispositivo = 'S' OR dispositivo = 'D'),-- A = APP(ANDROID), C = NAVEGADOR DO CELULAR, D = DESKTOP
	FOREIGN KEY(cod_funcionario) REFERENCES funcionario(cod_funcionario)
)