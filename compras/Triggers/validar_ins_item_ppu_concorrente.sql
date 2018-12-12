ALTER TRIGGER dbo.validar_ins_item_ppu_concorrenteON item_ppu_concorrenteFOR INSERT, UPDATEAS BEGIN	DECLARE @nnum_seq_item  		 INT,			  @ncod_forn_concorrente INT,			  @ncod_proc_adm 			 INT,			  @nnum_seq_ppu			 INT			  			SELECT				@nnum_seq_item  		  = INS.num_seq_item	,		@ncod_forn_concorrente = 94	,		@ncod_proc_adm			  = cl.cod_proc_adm						FROM INSERTED INS		INNER JOIN convite_licitacao cl ON			cl.cod_proc_adm = INS.cod_proc_adm				IF(NOT EXISTS(SELECT 						TOP 1 1 					   FROM ppu_concorrente						WHERE cod_proc_adm 		  = @ncod_proc_adm								AND cod_forn_concorrente = 94))	BEGIN		SELECT 			@nnum_seq_ppu = ISNULL(MAX(num_seq_ppu), 0 ) + 1		FROM ppu_concorrente		WHERE cod_proc_adm = @ncod_proc_adm				INSERT INTO ppu_concorrente(cod_proc_adm, cod_forn_concorrente, num_seq_ppu) VALUES(@ncod_proc_adm, @ncod_forn_concorrente, @nnum_seq_ppu)		IF(@@ERROR <> 0)		BEGIN			ROLLBACK			RAISERROR('TG(1): N�o foi poss�vel gerar a PPU PARA A EMPRESA GESTORA!', 16, 1)			RETURN 		END				INSERT INTO item_ppu_concorrente(num_seq_item, cod_mat_serv, cod_forn_concorrente, cod_proc_adm, qtd, prc_unit)		SELECT num_seq_item, 				 cod_mat_serv,				 @ncod_forn_concorrente,				 @ncod_proc_adm,				 AVG(qtd),				 AVG(prc_unit)		FROM item_ppu_concorrente		WHERE cod_proc_adm =  @ncod_proc_adm		GROUP BY num_seq_item,					cod_mat_serv							IF(@@ERROR <> 0)		BEGIN			ROLLBACK			RAISERROR('TG(2): N�o foi poss�vel cadastrar os itens da PPU m�dia!', 16, 1)			RETURN 		END	END	ELSE	BEGIN				DELETE item_ppu_concorrente WHERE cod_proc_adm = @ncod_proc_adm AND cod_forn_concorrente = @ncod_forn_concorrente		INSERT INTO item_ppu_concorrente(num_seq_item, cod_mat_serv, cod_forn_concorrente, cod_proc_adm, qtd, prc_unit)		SELECT num_seq_item, 				 cod_mat_serv,				 @ncod_forn_concorrente,				 @ncod_proc_adm,				 AVG(qtd),				 AVG(prc_unit)		FROM item_ppu_concorrente		WHERE cod_proc_adm =  @ncod_proc_adm				AND cod_forn_concorrente <> @ncod_forn_concorrente		GROUP BY num_seq_item,					cod_mat_serv								IF(@@ERROR <> 0)		BEGIN			ROLLBACK			RAISERROR('TG(3): N�o foi poss�vel cadastrar os itens da PPU m�dia!', 16, 1)			RETURN 		END			ENDEND