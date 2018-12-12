CREATE TRIGGER dbo.validar_del_movimento_despesa
ON movimento_despesa
--WITH ENCRYPTION 
FOR DELETE
AS 
BEGIN
	DECLARE @cod_conta_bancaria INT,
			  @valor  				 NUMERIC(15,3),
			  @cod_sit_mov 		 INT,
			  @cod_tip_mov 		 INT
	
	SELECT
		@cod_conta_bancaria = cod_conta_bancaria,
		@valor				  = valor		 ,
		@cod_sit_mov		  = cod_sit_mov ,
		@cod_tip_mov 		  = cod_tip_mov		
	FROM DELETED
	
	
	IF(@cod_sit_mov = 1)
	BEGIN
		ROLLBACK
		RAISERROR('TG.1) NÃO É POSSÍVEL EXCLUIR MOVIMENTAÇÃO FINANCEIRA JÁ EFETIVADA!', 16,1)
		RETURN
	END
END