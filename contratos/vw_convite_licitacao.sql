CREATE VIEW dbo.vw_convite_licitacao
AS 
SELECT 
	cl.descricao AS objeto,
	cl.data_abertura,
	cl.data_fechamento,
	cl.hora_fim, 
	cl.num_convite,
	cl.ano_convite,
	cl.cod_proc_adm,
	cl.cod_modl,
	cl.dat_inic_contr_est,
	cl.dat_fim_contr_est,
	c.razao_social,
	c.cod_cli,
	c.nome_fantasia,
	c.cnpj_cpf,
	cl.cod_empresa,
	c.logo,
	cl.cod_sit_conv
FROM compras..convite_licitacao cl
	INNER JOIN compras..cliente c ON
		c.cod_cli = cl.cod_cli
		AND c.cod_empresa = cl.cod_empresa
WHERE cod_sit_conv = 3