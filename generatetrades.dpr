program GenerateTrades;

{$mode delphi}

uses
  SysUtils, Classes, DateUtils;

const
  TradeCount = 1000000;

var
  F: TextFile;
  I: Integer;
  Symbols: array[0..5] of string;
  Exchanges: array[0..3] of string;
  Price: Double;
  Qty: Double;
  TS: TDateTime;

begin
  Randomize;

  Symbols[0] := 'BTCUSD';
  Symbols[1] := 'ETHUSD';
  Symbols[2] := 'SOLUSD';
  Symbols[3] := 'ADAUSD';
  Symbols[4] := 'XRPUSD';
  Symbols[5] := 'DOGEUSD';

  Exchanges[0] := 'BINANCE';
  Exchanges[1] := 'COINBASE';
  Exchanges[2] := 'KRAKEN';
  Exchanges[3] := 'OKX';

  AssignFile(F, 'trades.jsonl');
  Rewrite(F);

  TS := EncodeDateTime(2026, 10, 1, 0, 0, 0, 0);

  for I := 1 to TradeCount do
  begin
    case Random(6) of
      0: Price := 100000 + Random * 10000;  // BTC
      1: Price := 5000 + Random * 500;      // ETH
      2: Price := 200 + Random * 100;       // SOL
      3: Price := 1 + Random * 2;           // ADA
      4: Price := 2 + Random * 2;           // XRP
    else
      Price := 0.2 + Random * 0.5;          // DOGE
    end;

    Qty := 0.01 + Random * 100;

    Writeln(F,
      Format(
        '{"symbol":"%s","timestamp":"%s","price":%.2f,"quantity":%.4f,"exchange":"%s"}',
        [
          Symbols[Random(Length(Symbols))],
          FormatDateTime('yyyy"-"mm"-"dd"T"hh":"nn":"ss"Z"', TS),
          Price,
          Qty,
          Exchanges[Random(Length(Exchanges))]
        ]
      ));

    TS := IncMilliSecond(TS,Random(750));

    if (I mod 100000) = 0 then
      WriteLn(I, ' trades generated');
  end;

  CloseFile(F);

  WriteLn('Done.');
end.
