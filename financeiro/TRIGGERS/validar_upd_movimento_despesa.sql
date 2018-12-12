ALTER TRIGGER dbo.validar_upd_movimento_despesa
ON movimento_despesa
--WITH ENCRYPTION 
FOR UPDATE
AS 
BEGIN
	DECLARE @ocod_conta_bancaria INT				,
			  @ovalor  				 NUMERIC(15,3)	,
			  @ocod_sit_mov 		 INT				,
			  @ncod_conta_bancaria INT				,
			  @nvalor  				 NUMERIC(15,3)	,
			  @ncod_sit_mov 		 INT				,
			  @valor_saldo_final  NUMERIC(15,3)	,
			  @ocod_tip_mov 		 INT				,
			  @ncod_tip_mov 		 INT				,
			  @nro_interno			 INT				,
			  @cod_empresa 		 INT
	
	SELECT
		@ocod_conta_bancaria = cod_conta_bancaria,
		@ovalor				  = valor		 ,
		@ocod_sit_mov		  = cod_sit_mov ,
		@ocod_tip_mov		  = cod_tip_mov
	FROM DELETED
	
	
	SELECT
		@ncod_conta_bancaria = cod_conta_bancaria,
		@nvalor				   = ISNULL(valor_realizado, valor),
		@ncod_sit_mov		   = cod_sit_mov ,
		@ncod_tip_mov		   = cod_tip_mov ,
		@nro_interno 			= nro_interno ,
		@cod_empresa			= cod_empresa
	FROM INSERTED
	
	IF(@ncod_tip_mov <> @ocod_tip_mov)
	BEGIN
		ROLLBACK
		RAISERROR('TR.1) NÃO É POSSÍVEL MODIFICAR DE (RECEITA PARA DESPESA) OU DE (DESPESA PARA RECEITA)!', 16,1)
		RETURN
	END
	
	-- RECEITA
	IF(@ncod_tip_mov = 1)
	BEGIN			
			IF(@ocod_sit_mov = 2 AND @ncod_sit_mov = 1)
			BEGIN
				UPDATE conta_bancaria SET saldo = (saldo + @nvalor),
											data_saldo = GETDATE()
				WHERE cod_conta = @ncod_conta_bancaria
				IF(@@ERROR <> 0)
				BEGIN
					ROLLBACK
					RAISERROR('TR.2) NÃO FOI POSSÍVEL DEVOLVER O SALDO BANCÁRIO!', 16,1)
					RETURN
				END
			END
			
			IF(@ocod_sit_mov = 1 AND @ncod_sit_mov = 2)
			BEGIN
				UPDATE conta_bancaria SET saldo = (saldo - @nvalor),
											data_saldo = GETDATE()
				WHERE cod_conta = @ncod_conta_bancaria
				IF(@@ERROR <> 0)
				BEGIN
					ROLLBACK
					RAISERROR('TR.3) NÃO FOI POSSÍVEL DEVOLVER O SALDO BANCÁRIO!', 16,1)
					RETURN
				END
			END
	END

	-- DESPESAS
	IF(@ncod_tip_mov = 2)
	BEGIN
		IF(@ocod_sit_mov = 2 AND @ncod_sit_mov = 1)
		BEGIN
			-- ABATE O VALOR QUE ESTÁ SENDO PAGO PARA A DESPESA
			UPDATE conta_bancaria SET saldo = (saldo - @nvalor),
										data_saldo = GETDATE()
			WHERE cod_conta = @ncod_conta_bancaria
			IF(@@ERROR <> 0)
			BEGIN
				ROLLBACK
				RAISERROR('TR.2) NÃO FOI POSSÍVEL DEVOLVER O SALDO BANCÁRIO!', 16,1)
				RETURN
			END						
		END
		
		IF(@ocod_sit_mov = 1 AND @ncod_sit_mov = 2)
		BEGIN
			-- DEVOLVE O SALDO DA CONTA BANCÁRIA --
			UPDATE conta_bancaria SET saldo = (saldo + @nvalor),
										data_saldo = GETDATE()
			WHERE cod_conta = @ncod_conta_bancaria
			IF(@@ERROR <> 0)
			BEGIN
				ROLLBACK
				RAISERROR('TR.3) NÃO FOI POSSÍVEL DEVOLVER O SALDO BANCÁRIO!', 16,1)
				RETURN
			END
		END
	END
	
	-- TESTA O SALDO DA CONTA BANCÁRIA
	/*SELECT
		@valor_saldo_final = (ISNULL((SELECT
											 SUM(valor)
										 FROM movimento_despesa
										 WHERE nro_interno = @nro_interno	
												  AND cod_empresa = @cod_empresa
												  AND cod_conta_bancaria = @ncod_conta_bancaria
												  AND cod_sit_mov = 1
												  AND cod_tip_mov = 1),0)
										- 
										ISNULL((SELECT
											 SUM(valor_realizado)
										FROM movimento_despesa
										WHERE nro_interno = @nro_interno	
												AND cod_empresa = @cod_empresa
												AND cod_conta_bancaria = @ncod_conta_bancaria
												AND cod_sit_mov = 1
										AND cod_tip_mov = 2),0)) 
	IF(@valor_saldo_final < 0)	
	BEGIN
		ROLLBACK
		RAISERROR('TR.4) O SALDO DA CONTA BANCÁRIA IRÁ FICAR NEGATIVO. Contate o administrador do sistema.', 16,1)
		RETURN
	END*/
END