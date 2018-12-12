CREATE TABLE dbo.catalogo_preco(
	cod_proc_compr int not null,
	cod_forn int not null,
	codigo numeric(6,0) not null,
	prc_unit numeric(10,3) not null,
	dat_catalog datetime not null,
	primary key(cod_proc_compr, cod_forn, codigo),
	foreign key(cod_proc_compr) references processo_compra(cod_proc_compr),
	foreign key(cod_forn) references forencedor(cod_forn),
	foreign key(codigo) references material_servico(codigo),
)


CREATE TRIGGER dbo.validar_upd_processo_compra
ON processo_compra
--WITH ENCRYPTION 
FOR UPDATE
AS 
BEGIN
	DECLARE @ocod_sit_proc INT,
			  @ncod_sit_proc INT,
			  @ncod_proc_compr INT
			  
	SELECT
		@ocod_sit_proc = cod_sit_proc,
		@ncod_proc_compr = cod_proc_compr		
	FROM DELETETED
	
	SELECT
		@ncod_sit_proc = cod_sit_proc		
	FROM INSERTED
	
	-- processo finalizado
	IF(@ocod_sit_proc = 2 AND @ncod_sit_proc = 3)
	BEGIN
		INSERT INTO catalogo_preco(cod_proc_compr,
											cod_forn,
											codigo,
											prc_unit,
											dat_catalog)
					SELECT
						fcp.cod_proc_compr,
						fcp.cod_forn,
						icp.codigo,
						icp.prc_unit_mat,
						GETDATE()
					FROM fornecedor_cotacao_processo fcp
						INNER JOIN dbo.item_forn_cotacao_proc icp ON
							icp.cod_proc_compr = fcp.cod_proc_compr
							AND icp.cod_forn = fcp.cod_forn
					WHERE fcp.cod_proc_compr = @ncod_proc_compr
							AND fcp.idr_forn_venc = 1
				IF(@@ERROR <> 0)
				BEGIN
					ROLLBACK
					RAISERROR('Não foi possível gerar o catálogo de preços!', 16,1)
					RETURN
				END
	END
	
	IF(@ocod_sit_proc = 2 AND @ncod_sit_proc = 3)
	BEGIN
		DELETE catalogo_preco 
		WHERE cod_proc_compr = @ncod_proc_compr				
		IF(@@ERROR <> 0)
				BEGIN
					ROLLBACK
					RAISERROR('Não foi possível excluir o catálogo de preços informado!', 16,1)
					RETURN
				END					
	END
END