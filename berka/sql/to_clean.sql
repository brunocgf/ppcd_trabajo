\echo 'Berka(clean)'
\echo 'Programación para Ciencia de Datos'
\echo 'Adolfo De Unánue <unanue@itam.mx>'
\set VERBOSITY terse
\set ON_ERROR_STOP true

do language plpgsql $$ declare
    exc_message text;
    exc_context text;
    exc_detail text;
begin

  do $clean$ begin

   set search_path = clean, public;

  raise notice 'populating clients';
  drop table if exists clean.clients  cascade;

  create table clean.clients as ( --CTAS
    select
      client_id::int as client,
      case when substring(birth_number,3,2)::int > 12 then 'F' else 'M' end as gender,
      case when substring(birth_number,3,2)::int > 12
        then
          to_date(
            format('19%s%s%s',
                   substring(birth_number,1,2),
                   lpad((substring(birth_number,3,2)::int - 50)::varchar, 2,'0'),
                   (substring(birth_number,5,2))
            ),
            'YYYYMMDD')
      else
        to_date(format('19%s',birth_number), 'YYYYMMDD')
      end as bod,
      district_id::int as district
      from raw.client
    );

  create index clean_clients_client_ix on clean.clients (client);

  raise notice 'populating accounts';
  drop table if exists clean.accounts cascade;

  create table clean.accounts as (
    select
      account_id::integer as account,
      district_id::integer as district,
      fix_date(date) as date,
      case when lower(frequency) = 'poplatek mesicne' then 'monthly'
      when lower(frequency) = 'poplatek tydne' then 'weekly'
      when lower(frequency) = 'poplatek po obratu' then 'after transaction'
      end as frequency
      from raw.account
  );

  create index clean_accounts_loan_ix on clean.accounts (account);
  create index clean_accounts_district_ix on clean.accounts (district);
  create index clean_accounts_account_district_ix on clean.accounts (account, district);

  raise notice 'populating dispositions';
  drop table if exists clean.dispositions cascade;

  create table clean.dispositions as (
    select
      disp_id::integer as disposition,
      client_id::integer as client,
      account_id::integer as account,
      lower(btrim(type)) as type
      from raw.disp
  );

  create index clean_dispositions_disposition_ix on clean.dispositions(disposition);
  create index clean_dispositions_client_ix on clean.dispositions(client);
  create index clean_dispositions_account_ix on clean.dispositions(account);


  raise notice 'populating credit cards';
  drop table if exists clean.credit_cards cascade;

  create table clean.credit_cards as (
    select
      card_id::integer as credit_card,
      disp_id::integer as disposition,
      lower(btrim(type)) as type,
      fix_date(issued) as issued
      from raw.card
  );

  create index clean_credit_cards_credit_card_ix on clean.credit_cards (credit_card);
  create index clean_credit_cards_disposition_ix on clean.credit_cards (disposition);

  raise notice 'populating loans';
  drop table if exists clean.loans  cascade;

  create table clean.loans as (
    select
      loan_id::integer as loan,
      account_id::integer as account,
      fix_date(date) as date,
      amount::numeric(10,2) as amount,
      format('P%sM', duration)::interval as duration,
      payments::numeric(10,2) as monthly_payment,
      btrim(lower(status)) as status
  from raw.loan
  );

  create index clean_loans_loan_ix on clean.loans (loan);
  create index clean_loans_account_ix on clean.loans (account);
  create index clean_loans_account_loan_ix on clean.loans (account, loan);

  raise notice 'populating transactions';
  drop table if exists clean.transactions cascade;

  create table clean.transactions as (
    select
      trans_id::integer as transaction,
      account_id::integer as account,
      fix_date(date) as date,
      case  lower(btrim(type))
      when 'prijem' then 'credit'
      when 'vydaj' then 'withdraw'
      else 'withdraw' end as type, /* Los valores faltantes tienen "Withdrawal in Cash" en la columna de operation */
      case lower(btrim(operation))
      when 'vyber kartou' then 'credit card withdrawal'
      when 'vklad' then 'credit in cash'
      when 'prevod z uctu' then 'collection from another bank'
      when 'vyber' then 'withdrawal in cash'
      when 'prevod na ucet' then 'remittance to another bank' end as mode,
      fix_numeric(amount) as amount,
      fix_numeric(balance) as balance,
      case lower(btrim(k_symbol)) when 'pojistne' then 'insurance payment'
      when 'sluzby' then 'payment for statement'
      when 'urok' then 'interest credited'
      when 'sankc.urok' then 'sanction interest'
      when 'sipo' then 'household'
      when 'duchod' then 'old-age pension'
      when 'uver' then 'loan payment' end as k_symbol,
      lower(btrim(bank)) as partner_bank,
      account::integer as partner_account
      from raw.trans
  );

  create index clean_transactions_transaction_ix on clean.transactions(transaction);

  create index clean_transactions_account_ix on clean.transactions(account);

  raise notice 'populating permantent orders';
  drop table if exists clean.permanent_orders cascade;

  create table clean.permanent_orders as (
    select
      order_id::integer as  order,
      account_id::integer as issuer,
      lower(btrim(bank_to)) as bank,
      account_to::integer as recipient,
      fix_numeric(amount) as amount,
      case lower(btrim(k_symbol))
      when 'pojistne' then 'insurance payment'
      when 'sipo' then 'household'
      when 'leasing'  then 'leasing'
      when 'uver' then 'loan payment'
      end as k_symbol
      from raw."order"
  );

  create index clean_permanent_orders_issuer_ix on clean.permanent_orders(issuer);
  create index clean_permanent_orders_recipient_ix on clean.permanent_orders(recipient);

  raise notice 'populating districts';
  drop table if exists clean.districts cascade;

  create table clean.districts as (
    select
      "A1"::integer as district,
      lower(btrim("A2")) as name,
      lower(btrim("A3")) as region,
      fix_int("A4") as inhabitans,
      fix_int("A5") as small_municipalities,
      fix_int("A6") as medium_municipalities,
      fix_int("A7") as large_municipalities,
      fix_int("A8") as huge_municipalities,
      fix_int("A9") as cities,
      fix_numeric("A10") as urban_inhabitans_ratio,
      fix_numeric("A11") as average_salary,
      fix_numeric("A12") as unemployment_rate_1995,
      fix_numeric("A13") as unemployment_rate_1996,
      fix_int("A14") as entrepreneurs_per_thousand_inhabitans,
      fix_int("A15") as commited_crimes_1995,
      fix_int("A16") as commited_crimes_1996
      from raw.district
  );

  create index clean_districts_district_ix on clean.districts(district);

  comment on column clean.districts.small_municipalities is '< 499 inhabitans';
  comment on column clean.districts.medium_municipalities is 'between 500 and 1,999 inhabitans';
  comment on column clean.districts.large_municipalities is 'between 2,000 and 9,999 inhabitans';
  comment on column clean.districts.huge_municipalities is '> 10,000 inhabitans';

  end $clean$;

exception when others then
    get stacked diagnostics exc_message = message_text;
    get stacked diagnostics exc_context = pg_exception_context;
    get stacked diagnostics exc_detail = pg_exception_detail;
    raise exception E'\n------\n%\n%\n------\n\nCONTEXT:\n%\n', exc_message, exc_detail, exc_context;
end $$;
