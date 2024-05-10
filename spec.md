# Техническое задание

Вторая стратегия на ETHUSDT 3H.
Вход в позицию на $100 000.
Вход и выход в позиции по индикатору ADX.

# Фичи и чек-лист приемки

- [x] Вход в позизию:
    - [x] лонг: Если индикатор ADX за 24 свечи ниже 50 и нету открытых позиций, тогда покупаем стоп ордером наивысший хай за 46 свечей.
    - [x] шорт: Если индикатор ADX за 24 свечи ниже 50 и нету открытых позиций, тогда шортим стоп ордером наинизший лоу за 46 свечей.
- [x] Выход из позиции: 
    - [x] 1. Если (хай - открытие) свечи больше чем (хай - лоу прошлой свечи умноженной на 2)
    - [x] 2. По стопу 3000
    - [x] 3. По тейку 4500
    - [x] 4. Как только открытый профит достигает 2000 — выставляем стоп в безубыток

# Код для TradeStation:

```
Inputs: LenX(46), ProfitX(3000);    
   
If ADX(24) < 50 then begin                                                          
If marketposition = 0 then buy next bar at highest(h,LenX) stop;
end;

If ADX(24) < 50  then begin
If marketposition = 0 then sellshort next bar at lowest(l,LenX) stop;
end;

if marketposition > 0 then begin
   if absvalue(high-open) > 2*(high[1]-low[1]) then sell next bar at market;
 end;
 
if marketposition < 0 then begin 
  if absvalue(high-open) > 2*(high[1]-low[1]) then buytocover next bar at market;
end;

If openpositionprofit > ProfitX*1.5 then begin; 
    sell next bar market; 
    buytocover next bar market; 
end;

setstoploss(ProfitX);
Setbreakeven(ProfitX/1.5);
```