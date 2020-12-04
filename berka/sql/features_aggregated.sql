create schema if not exists features;

drop table if exists features.aggregated;

create table if not exists features.aggregated as (
select * from
(
  select
    as_of_date,
    client
    from
        labels.loan_granted_3m
) as aod
             left join lateral ( -- for loop
               select
                 count(*) filter(where daterange((aod.as_of_date - interval '1 month')::date, aod.as_of_date::date) @> date) as "COUNT(*, @1M)",
                 count(*) filter(where daterange((aod.as_of_date - interval '3 month')::date, aod.as_of_date::date) @> date) as "COUNT(*, @3M)",
                 count(*) filter(where daterange((aod.as_of_date - interval '1 month')::date, aod.as_of_date::date) @> date and type='withdrawal in cash')  as "COUNT(withdrawal in cash, @1M)",
count(*) as "COUNT(*)"
                 from semantic.events
                where aod.client = client
             ) as t2
                 on true
);
create index features_aggregated_as_of_date_ix on features.aggregated(as_of_date);
create index features_aggregated_client_ix on features.aggregated(client);
create index features_aggregated_client_as_of_date_ix on features.aggregated(client, as_of_date);
