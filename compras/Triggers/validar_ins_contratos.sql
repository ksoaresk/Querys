ALTER TRIGGER dbo.validar_ins_contratos
ON contratos
--WITH ENCRYPTION 
FOR INSERT
AS 
BEGIN
	DECLARE @num_contr VARCHAR(20) ,
			  @ano_contr NUMERIC(4,0),
			  @cod_proc_adm INT		 ,
			  @nro_interno INT		 ,
			  @cod_empresa INT		 ,
			  @cod_ccust  INT			 , 
			  @nome_ccust VARCHAR(64), 
			  @cidade_codigo	INT	 , 
			  @uf_codigo INT			 ,
			  @cod_ccust_new		 INT
			  
	SELECT
		@num_contr 	  = num_contr	,
		@ano_contr	  = ano_contr	,
		@cod_proc_adm = cod_proc_adm,
		@nro_interno  = nro_interno,
		@cod_empresa  = cod_empresa
	FROM INSERTED
	
	
	--TRATAMENTO CASO O CADASTRO SEJA VINDO DE UMA LICITAÇÃO
	IF(@cod_proc_adm IS NOT NULL)
	BEGIN
		IF(EXISTS(SELECT TOP 1 1 FROM centro_custo_licitacao	 WHERE cod_proc_adm = @cod_proc_adm))
		BEGIN
			DECLARE C_CENTRO_CUSTO_LICITACAO CURSOR LOCAL FOR
			SELECT 
				cod_ccust,
				nome_ccust,
				cidade_codigo,
				uf_codigo
			FROM centro_custo_licitacao
			WHERE cod_proc_adm = @cod_proc_adm
			
			OPEN C_CENTRO_CUSTO_LICITACAO
			
			FETCH NEXT FROM C_CENTRO_CUSTO_LICITACAO INTO @cod_ccust, @nome_ccust, @cidade_codigo, @uf_codigo
			WHILE @@FETCH_STATUS = 0
			BEGIN
				-- CADASTRA O CENTRO DE CUSTO --
				INSERT INTO centro_custo(nome_ccust, nro_interno, cod_empresa, uf_codigo, cidade_codigo) VALUES(@nome_ccust, @nro_interno, @cod_empresa, @uf_codigo, @cidade_codigo)
				-- VERIFICA SE HOUVE ERRO NO CADASTRO --
				IF(@@ERROR <> 0)
				BEGIN
					ROLLBACK
					RAISERROR('TG) Não foi possível O CENTRO DE CUSTO.', 16, 1)
					RETURN
				END
				-- CADASTRA OS ITENS DO CONTRATO
				SET @cod_ccust_new = IDENT_CURRENT( 'centro_custo' )
				INSERT INTO item_ppu_contrato(num_seq_item, cod_mat_serv, descricao, qtd, prc_unit, nro_interno, cod_empresa, cod_unid_med, cod_ccust)
				SELECT 
					num_seq_item	,
					cod_mat_serv	,
					UPPER(descricao),
					qtd				,
					prc_unit			,
					@nro_interno	, 
					@cod_empresa	,
					cod_unid_med	,
					@cod_ccust_new
				FROM item_convite_licitacao 
				WHERE cod_proc_adm = @cod_proc_adm
						AND cod_ccust = @cod_ccust
				IF(@@ERROR <> 0)
				BEGIN
					ROLLBACK
					RAISERROR('TG) NÃO FOI POSSÍVEL INCLUIR OS ITENS NO CENTRO DE CUSTO INFORMADO!', 16, 1)
					RETURN
				END
				
				-- PASSA PARA O PRÓXIMO ITEM DA LISTA
				FETCH NEXT FROM C_CENTRO_CUSTO_LICITACAO INTO @cod_ccust, @nome_ccust, @cidade_codigo, @uf_codigo
			END
		END
		ELSE
		BEGIN
			-- CADASTRA OS ITENS
			INSERT INTO item_ppu_contrato(num_seq_item, cod_mat_serv, descricao, qtd, prc_unit, nro_interno, cod_empresa, cod_unid_med)
			SELECT 
				num_seq_item	,
				cod_mat_serv	,
				UPPER(descricao),
				qtd				,
				prc_unit			,
				@nro_interno	, 
				@cod_empresa	,
				cod_unid_med	
			FROM item_convite_licitacao 
			WHERE cod_proc_adm = @cod_proc_adm
		END
	END
END

