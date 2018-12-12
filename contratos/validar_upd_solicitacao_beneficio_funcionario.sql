CREATE TRIGGER dbo.validar_upd_solicitacao_beneficio_funcionario
ON solicitacao_beneficio_funcionario
--WITH ENCRYPTION 
FOR UPDATE
AS 
BEGIN
	DECLARE @o_situacao CHAR(1)					,
			  @n_situacao CHAR(1)					
	
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
END