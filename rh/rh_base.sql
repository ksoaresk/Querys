use sgidoc
CREATE TABLE dbo.escolaridade_funcionario(
	cod_esco int not null identity(1,1),
	descricao varchar(64) not null,
	primary key(cod_esco)
)

insert into escolaridade_funcionario(descricao) values('Analfabeto')
insert into escolaridade_funcionario(descricao) values('Até 4ª série incompleta do 1º grau (ensino fundamental)')
insert into escolaridade_funcionario(descricao) values('4ª série completa do 1º grau (ensino fundamental)')
insert into escolaridade_funcionario(descricao) values('5ª a 8ª série incompleta do 1º grau (ensino fundamental)')
insert into escolaridade_funcionario(descricao) values('1º grau completo (ensino fundamental)')
insert into escolaridade_funcionario(descricao) values('2º grau incompleto (ensino médio)')
insert into escolaridade_funcionario(descricao) values('2º grau completo (ensino médio)')
insert into escolaridade_funcionario(descricao) values('Superior Incompleto')
insert into escolaridade_funcionario(descricao) values('Superior Completo')
insert into escolaridade_funcionario(descricao) values('Pós-Graduação/Especialização')
insert into escolaridade_funcionario(descricao) values('Mestrado')
insert into escolaridade_funcionario(descricao) values('Doutorado')
insert into escolaridade_funcionario(descricao) values('Pós-Doutorado')

CREATE TABLE dbo.funcionario(
	cod_funcionario int not null identity(1,1),
	nome varchar(64) not null,
	matricula int null,	
	nro_interno int not null,
	cod_empresa int not null,
	nome_mae varchar(64) NULL,
	nome_pai varchar(64) null,
	cep varchar(8) NULL,
	logradouro varchar(30) null,
	bairro varchar(30) null,
	cidade varchar(30) null,
	estado varchar(10) null,
	nacionalidade varchar(20) null,
	naturalidade varchar(20) null,
	cod_esco int null,
	sexo char(1) null,
	estado_civil char(1) null,
	data_nascimento datetime null,
	idr_deficiente char(1) null default 'N',	
	foto image,
	extensao varchar(4),
	PRIMARY KEY(cod_funcionario),	
	FOREIGN KEY(nro_interno, cod_empresa) REFERENCES contratos(nro_interno, cod_empresa),
	check(sexo = 'M' OR sexo = 'F' OR sexo = 'O'),
	check(estado_civil = 'S' OR estado_civil = 'C' OR estado_civil = 'O'),
	check(idr_deficiente = 'S' OR idr_deficiente = 'N')
)

CREATE TABLE dbo.funcionario_contato
(
	cod_contato int NOT NULL 												 ,
	cod_funcionario int not null											 ,
	descricao varchar (64) COLLATE Latin1_General_CI_AI NOT NULL ,
	tipo varchar (5) COLLATE Latin1_General_CI_AI NOT NULL 		 ,
	nome_contato varchar (200) COLLATE Latin1_General_CI_AI NULL ,
	departamento varchar (100) COLLATE Latin1_General_CI_AI NULL ,	
	PRIMARY KEY(cod_contato, cod_funcionario),
	FOREIGN KEY(cod_funcionario) REFERENCES funcionario(cod_funcionario) ON DELETE CASCADE ,
	CHECK (tipo = 'TEL' or tipo = 'EMAIL' or tipo = 'FAX')
)

CREATE TABLE dbo.funcionario_cargo(
	cod_cargo int not null					,
	cod_funcionario int not null			,
	cod_ocupacao_cbo varchar(6) not null,
	cod_familia_cbo varchar(4) not null ,
	data_admissao datetime null			,
	data_demissao datetime null			,
	cod_setor int not null					,
	data_op_fgts datetime null				,
	salario_atual NUMERIC(15,3) NOT NULL,
	descanso VARCHAR(30) NOT NULL,
	horas_mes VARCHAR(10) NOT NULL,
	horas_semana VARCHAR(10) NOT NULL,	
	PRIMARY KEY(cod_cargo, cod_funcionario),
	FOREIGN KEY(cod_funcionario) REFERENCES funcionario(cod_funcionario) ON DELETE CASCADE,
	FOREIGN  KEY(cod_ocupacao_cbo, cod_familia_cbo) REFERENCES ocupacao_cbo(cod_ocupacao_cbo, cod_familia_cbo),
	FOREIGN KEY(cod_setor) REFERENCES setor(cod_setor)
)

sp_help ocupacao_cbo