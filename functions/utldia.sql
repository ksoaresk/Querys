CREATE FUNCTION dbo.ULTMDIA(@dia INT, @mes VARCHAR(2), @ano VARCHAR(4))
RETURNS INT
BEGIN

	DECLARE @ultimo_dia_mes INT
	SET @ultimo_dia_mes = DAY(DATEADD(d,-1,DATEADD(M,1,CONVERT(DATETIME, @ano + RIGHT('00'+@mes,2) + '01'))))

	IF(@dia = 28 AND CAST(@mes AS INT) = 2) 
		SET @dia = @ultimo_dia_mes

	IF(@dia > 28 AND CAST(@mes AS INT) = 2) 
		SET @dia = @ultimo_dia_mes

	IF( @dia > @ultimo_dia_mes )
		SET @dia = @ultimo_dia_mes

	
   RETURN @dia
   
END