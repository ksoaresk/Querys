CREATE TRIGGER dbo.validar_ins_pessoal_dfp
ON pessoal_dfp
WITH ENCRYPTION 
FOR INSERT, UPDATE
AS 
BEGIN
	DECLARE @cod_proc_adm INT,
			  @cod_estru_dfp INT
			  
	SELECT
		@cod_proc_adm = cod_proc_adm,
		@cod_estru_dfp= cod_estru_dfp
	FROM INSERTED
	
	IF(NOT EXISTS(SELECT TOP 1 1 FROM encargos_pessoal_dfp WHERE cod_proc_adm = @cod_proc_adm))
	BEGIN
		ROLLBACK
		RAISERROR('Primeiro é necessário fazer a inclusão dos encargos com pessoal para dar continuidade a esta estrutura.', 16, 1)
		RETURN
	END
	
	
	UPDATE convite_estrutura_dfp SET cod_sit_conv_estru = 3 WHERE cod_proc_adm = @cod_proc_adm AND cod_estru_dfp = @cod_estru_dfp AND cod_sit_conv_estru = 2
	IF(@@ERROR <> 0)
	BEGIN
		ROLLBACK
		RAISERROR('Não foi possível atualizar a situação do item da estrutura da DFP', 16, 1)
		RETURN
	END
END
