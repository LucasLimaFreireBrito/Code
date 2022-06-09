/*
Create Or Replace Function paposql.fun_eh_data_util("p_data" timestamp with time zone)
     Returns boolean As
$Body$
Begin
     Return (date_part('dow', p_data) <> 0 And date_part('dow', p_data) <> 6);
End;
$Body$
Language 'plpgsql'
Volatile
Called On Null Input
Security Invoker
Cost 100;
*/

-- Dias da Semana // Sabado ou Domingo
select date_part('isodow', '2022-06-11'::dm_dt) <> 6 
union all
select date_part('isodow', '2022-06-12'::dm_dt) <> 7;

-- Gerando dias uteis em intervalo com 60 dias
select 	serie.data_g, 
		date_part('isodow', serie.data_g) as DiaSemana		
from (select generate_series('01-06-2022'::dm_dt, dateadd('day', 83, '01-06-2022')::dm_dt,'1 DAY') as data_g) serie
where date_part('isodow', serie.data_g) not in (6, 7)
order by serie.data_g;

-- Retornando o primeiro dia util
select 	serie.data_g, 
		date_part('isodow', serie.data_g) as DiaSemana,
		TO_CHAR(serie.data_g, 'DD/MM'),
		tf.*
from (select generate_series('05-06-2022'::dm_dt /*:DT_VENCIMENTO*/, dateadd('day', 83, '07-06-2022'/*:DT_VENCIMENTO*/)::dm_dt,'1 DAY') as data_g) serie
left join tb_feriado tf on TO_CHAR(serie.data_g, 'DD/MM') = tf.DATA
where date_part('isodow', serie.data_g) not in (6, 7)
and   tf.id_feriado is null
order by serie.data_g
limit 1

-- Primeiro e Ultimo dia util do mes
SELECT 	EXTRACT(DAY FROM min(dias)) AS primeiro_dia_util,
		EXTRACT(DAY FROM max(dias)) AS ultimo_dia_util
FROM generate_series(date_trunc('month',current_date),
					 date_trunc('month',current_date) + INTERVAL'1 month' - INTERVAL'1 day',
					 INTERVAL'1 day') AS dias
WHERE EXTRACT(ISODOW FROM dias) < 6 
AND NOT EXISTS (SELECT data FROM feriados WHERE dias = data);
