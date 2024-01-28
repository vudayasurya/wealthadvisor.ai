CREATE DATABASE stock
WITH ENGINE = 'postgres',
PARAMETERS = {
    "user": "demo_user",
    "password": "demo_password",
    "host": "3.220.66.106",
    "port": "5432",
    "database": "demo"
    };

CREATE OR REPLACE TABLE stock.stockusers
 (
   SELECT * 
   FROM files.user_01_28_final
   --FROM files.USERS
 );

 CREATE OR REPLACE TABLE stock.stock_lives
 (
   SELECT * 
   from files.live_stocks_01_28
   --FROM files.LIVE_STOCK
 );

CREATE OR REPLACE TABLE stock.live_news
 (
   SELECT *
   from files.live_news_01_28
   --FROM files.LIVE_NEWS1
 );

CREATE ML_ENGINE openai_engine_udaya
FROM openai
USING
    api_key = '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';

-- CREATE MODEL gpt_model_udaya_01_28
-- PREDICT response
-- USING
--   engine = 'openai_engine_udaya',
--   api_key = 'XXXX',
--   model_name = 'gpt-4', -- you can also use 'text-davinci-003', 'gpt-3.5-turbo'
--   prompt_template ='rank the rating from 0 to 10: {{comment}}';

-- SELECT output.response, input.NEWS
-- FROM stock.live_news AS input
-- JOIN gpt_model_udaya_01_28 AS output
-- --JOIN mindsdb.gpt_model_stock_insights_1 AS output
-- LIMIT 3;


CREATE MODEL gpt_model_stock_insights_2022
PREDICT response
USING
  engine = 'openai_engine_udaya',
  api_key = 'XXXX',
  model_name = 'gpt-4', -- you can also use 'text-davinci-003', 'gpt-3.5-turbo'
  prompt_template ='I am stock trader. I want to buy stock based on latest news.classify the sentiment of the news and assign values 
strictly as 1, 0, or -1. 1 means news is positive, 0 means news is neutral,-1 means news in negative,  No text needed only numbers please
{{news}}';


CREATE MODEL gpt_model_stock_insights_2022
PREDICT response
USING
  engine = 'openai_engine_udaya',
  api_key = 'XXXX',
  model_name = 'gpt-4', -- you can also use 'text-davinci-003', 'gpt-3.5-turbo'
  prompt_template ='I am stock trader. I want to buy stock based on previous investments.classify the sentiment of the news and assign values 
strictly as 1, 0, or -1. 1 means news is positive, 0 means news is neutral,-1 means news in negative,  No text needed only numbers please
{{news}}';

CREATE OR REPLACE TABLE stock.FINAL_BUY_PREDICTION 
( 
SELECT ticker,
       SUM(response) AS RECOMMENDED_ACTION
FROM (
SELECT cast(output.response as integer), input.ticker,
       input.news, 
       RANK() OVER (PARTITION BY ticker ORDER BY published_on DESC) AS RANK_DONE
FROM stock.live_news AS input
JOIN mindsdb.gpt_model_stock_insights_2022 AS output
) WHERE RANK_DONE = 1
GROUP BY 1);




CREATE OR REPLACE TABLE stock.FINAL_STOCK_ACTION
(
SELECT 
*
FROM stock.stockusers AS s 
LEFT JOIN stock.stock_lives AS l ON s.Ticker = l.symbol
LEFT JOIN stock.FINAL_BUY_PREDICTION F ON s.Ticker =F.ticker 
);

SELECT * FROM stock.FINAL_STOCK_ACTION where user_id = 585171;
