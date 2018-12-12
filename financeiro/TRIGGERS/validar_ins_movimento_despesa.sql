CREATE TRIGGER dbo.validar_ins_movimento_despesa
ON movimento_despesa
--WITH ENCRYPTION 
FOR INSERT
AS 
BEGIN
	DECLARE @cod_conta_bancaria INT,
			  @valor  				 NUMERIC(15,3),
			  @valor_realizado	 NUMERIC(15,3),
			  @cod_sit_mov 		 INT,
			  @cod_tip_mov 		 INT,
			  @nro_interno			 INT,
			  @cod_empresa 		 INT,
			  @valor_saldo_final	 NUMERIC(15,3)
	
	SELECT
		@cod_conta_bancaria = cod_conta_bancaria,
		@valor				  = valor		 ,
		@cod_sit_mov		  = cod_sit_mov ,
		@cod_tip_mov 		  = cod_tip_mov ,
		@valor_realizado    = valor_realizado,
		@nro_interno		  = nro_interno ,
		@cod_empresa		  = cod_empresa
	FROM INSERTED
	
	-- RECEITA
	IF(@cod_tip_mov = 1 AND @cod_sit_mov = 1)
	BEGIN		
		UPDATE conta_bancaria SET saldo = (saldo + @valor),
											data_saldo = GETDATE()
		WHERE cod_conta = @cod_conta_bancaria
		IF(@@ERROR <> 0)
		BEGIN
			ROLLBACK
			RAISERROR('TG.1) NÃO FOI POSSÍVEL ATUALIZAR O SALDO BANCÁRIO!', 16,1)
			RETURN
		END		
	END
	
	-- DESPESA
	IF(@cod_tip_mov = 2 AND @cod_sit_mov = 1)
	BEGIN 
		UPDATE conta_bancaria SET saldo = (saldo - @valor),
										  data_saldo = GETDATE()
		WHERE cod_conta = @cod_conta_bancaria
		IF(@@ERROR <> 0)
		BEGIN
			ROLLBACK
			RAISERROR('TG.2) NÃO FOI POSSÍVEL ATUALIZAR O SALDO BANCÁRIO!', 16,1)
			RETURN
		END
	END	
	
	/*SELECT
		@valor_saldo_final = (ISNULL((SELECT
											 SUM(valor)
										 FROM movimento_despesa
										 WHERE nro_interno = @nro_interno	
												  AND cod_empresa = @cod_empresa
												  AND cod_conta_bancaria = @cod_conta_bancaria
												  AND cod_sit_mov = 1
												  AND cod_tip_mov = 1),0)
										- 
										ISNULL((SELECT
											 SUM(valor_realizado)
										FROM movimento_despesa
										WHERE nro_interno = @nro_interno	
												AND cod_empresa = @cod_empresa
												AND cod_conta_bancaria = @cod_conta_bancaria
												AND cod_sit_mov = 1
										AND cod_tip_mov = 2),0)) 			
		IF(@valor_saldo_final < 0 )
		BEGIN
			ROLLBACK
			RAISERROR('TR.3) O SALDO DA CONTA BANCÁRIA INFORMADA IRÁ FICAR NEGATIVO.', 16,1)
			RETURN
		END*/
END