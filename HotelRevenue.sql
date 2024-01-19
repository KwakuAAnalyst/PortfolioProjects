
with hotels as 
(SELECT *
  FROM [PortfolioProject].[dbo].[yr2018]
  union
SELECT *
  FROM [PortfolioProject].[dbo].[yr2019]
  union
SELECT *
  FROM [PortfolioProject].[dbo].[yr2020])

  select 
		arrival_date_year,
		round(sum((stays_in_week_nights+stays_in_weekend_nights) * adr), 2) as revenue,
		 hotel
  from hotels
  group by arrival_date_year, hotel

  ---------------------------------------------------------------------------------------------
  */


with hotels as 
(SELECT *
  FROM [PortfolioProject].[dbo].[yr2018]
  union
SELECT *
  FROM [PortfolioProject].[dbo].[yr2019]
  union
SELECT *
  FROM [PortfolioProject].[dbo].[yr2020])

  select * 
  from hotels
  left join [PortfolioProject].[dbo].[market_segment]
  on hotels.market_segment = market_segment.market_segment
  left join [PortfolioProject].[dbo].[meal_cost]
  on meal_cost.meal = hotels.meal
 