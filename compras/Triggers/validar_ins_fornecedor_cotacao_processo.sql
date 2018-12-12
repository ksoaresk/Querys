CREATE TRIGGER dbo.validar_ins_fornecedor_cotacao_processo
ON fornecedor_cotacao_processo
WITH ENCRYPTION 
FOR INSERT
AS 
BEGIN		
	INSERT INTO item_forn_cotacao_proc(cod_proc_compr,
												  cod_forn		 ,
												  codigo			 ,
												  qtd_mat_solicit,
												  prc_unit_mat)
	
	
	SELECT
		ins.cod_proc_compr,
		ins.cod_forn,
		ism.codigo,
		SUM(ism.qtd_mat_solicit),
		0
	FROM INSERTED ins
		INNER JOIN item_solicitacao_material ism ON
			ism.cod_proc_compr = ins.cod_proc_compr
	GROUP BY ins.cod_proc_compr,
				ins.cod_forn,
				ism.codigo				
	IF(@@ERROR <> 0)
	BEGIN
		ROLLBACK
		RAISERROR('TG) Não foi possível cadastrar os itens da cotação do fornecedor informado.', 16, 1)
		RETURN
	END
END
