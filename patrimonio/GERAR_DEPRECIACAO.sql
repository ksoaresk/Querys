CREATE PROCEDURE DBO.GERAR_DEPRECIACAO 
--WITH ENCRYPTION
AS
BEGIN
	DECLARE @QTD_MES 				 INT,
			  @COD_PATR 			 INT,
			  @TX_MES_DEPREC 		 NUMERIC(15, 3),
			  @TX_ANO_DEPREC  	 NUMERIC(15, 3),
			  @DATA_ULTM_DEPREC 	 DATETIME	  ,
			  @VLR_PATRIMONIO 	 NUMERIC(15, 3),
			  @NRO_INTERNO	   	 INT,
			  @COD_EMPRESA 		 INT,
			  @COD_SETOR			 INT,
			  @VLR_DEPREC			 NUMERIC(15,3),
			  @VLR_PATRIMONIO_OLD NUMERIC(15, 3)

	DECLARE C_PATRIMONIO CURSOR LOCAL FOR
		SELECT
			ISNULL(p.data_ultm_deprec, ISNULL(p.data_nota_fiscal, p.data_cadastro)) AS data_ultm_deprec,
			cod_patr,
			DATEDIFF(MONTH, ISNULL(p.data_ultm_deprec, ISNULL(p.data_nota_fiscal, p.data_cadastro)), GETDATE()),
			gd.taxa_ano_deprec,
			ISNULL(p.valor_residual, ISNULL(p.valor_nota_fiscal, 0)),
			p.nro_interno,
			p.cod_empresa,
			p.cod_setor
		FROM patrimonio p
			INNER JOIN grupo_depreciacao gd ON
				gd.cod_grupo_deprec = p.cod_grupo_deprec
		WHERE p.cod_baixa IS NULL
				AND ISNULL(gd.taxa_ano_deprec,0) > 0
				AND DATEDIFF(MONTH, ISNULL(p.data_ultm_deprec, ISNULL(p.data_nota_fiscal, p.data_cadastro)), GETDATE()) > 0
				AND ISNULL(p.valor_residual, ISNULL(p.valor_nota_fiscal, 0)) > 0

	OPEN C_PATRIMONIO

	FETCH NEXT FROM C_PATRIMONIO INTO @DATA_ULTM_DEPREC, 
												 @COD_PATR			,
												 @QTD_MES			,
												 @TX_ANO_DEPREC	,
												 @VLR_PATRIMONIO	,
												 @NRO_INTERNO		,
												 @COD_EMPRESA		,
												 @COD_SETOR		



	WHILE @@FETCH_STATUS = 0
	BEGIN
			-- GERA DEPRECIAÇÃO MÊS A MES DO BEM
			SET @TX_MES_DEPREC 	 	= (@TX_ANO_DEPREC / 12);
			SET @VLR_PATRIMONIO_OLD = NULL
			
			-- GERA DEPRECIAÇÃO A CADA MÊS
			WHILE(@QTD_MES > 0)
			BEGIN								
				IF(@VLR_PATRIMONIO_OLD IS NULL)
					SET @VLR_PATRIMONIO_OLD = @VLR_PATRIMONIO;
				
				SET @VLR_DEPREC    	   = (@VLR_PATRIMONIO_OLD * @TX_MES_DEPREC) / 100;
				

				-- GERA DUAS MOVIMENTAÇÕES UMA DE SAÍDA DO VALOR E OUTRA DE ENTRADA DO NOVO VALOR
				INSERT INTO movimentacao_material(cod_patr		, 
															 tipo				, 
															 tipo_movimento, 
															 vlr_mov			, 
															 observacao		, 
															 nro_interno	, 
															 cod_empresa	, 
															 cod_setor)
													VALUES(@COD_PATR		,
															 'S'				, --SAÍDA
															 'D'				, --DEPRECIAÇÃO
															 @VLR_PATRIMONIO_OLD,
															 'DEPRECIAÇÃO'	,
															 @NRO_INTERNO	,
															 @COD_EMPRESA	,
															 @COD_SETOR)
				
				-- ENTRADA
				SET @VLR_PATRIMONIO_OLD = @VLR_PATRIMONIO_OLD - @VLR_DEPREC;
				INSERT INTO movimentacao_material(cod_patr		, 
															 tipo				, 
															 tipo_movimento, 
															 vlr_mov			, 
															 observacao		, 
															 nro_interno	, 
															 cod_empresa	, 
															 cod_setor)
													VALUES(@COD_PATR		,
															 'E'				, --ENTRADA
															 'D'				, --DEPRECIAÇÃO
															 @VLR_PATRIMONIO_OLD,
															 'DEPRECIAÇÃO'	,
															 @NRO_INTERNO	,
															 @COD_EMPRESA	,
															 @COD_SETOR)
															 
				SET @QTD_MES = (@QTD_MES - 1);
			END
			
			-- ATUALIZA INFORMAÇÕES DE DEPRECIAÇÃO NO PATRIMÔNIO --				
			UPDATE patrimonio SET valor_residual = @VLR_PATRIMONIO_OLD, data_ultm_deprec = GETDATE() WHERE cod_patr = @COD_PATR

			-- MOVE O CURSOR PARA O PRÓXIMO REGISTRO
			FETCH NEXT FROM C_PATRIMONIO INTO @DATA_ULTM_DEPREC, 
											  @COD_PATR			,
											  @QTD_MES			,
											  @TX_ANO_DEPREC	,
											  @VLR_PATRIMONIO	,
											  @NRO_INTERNO		,
											  @COD_EMPRESA		,
											  @COD_SETOR			
	END
	
	CLOSE C_PATRIMONIO;
	DEALLOCATE C_PATRIMONIO;
END