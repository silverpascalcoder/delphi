program TradeProcessor;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.IOUtils,
  System.Classes,
  System.JSON,
  System.Generics.Collections,
  System.Diagnostics,
  System.Threading;

type
  TSymbolStats = record
    Count: Int64;
    Volume: Double;
    Value: Double;
    HighPrice: Double;
    LowPrice: Double;
  end;

var
  Stats: TDictionary<string, TSymbolStats>;
  Lines: TArray<string>;
  Stopwatch: TStopwatch;
  LockObj: TObject;

begin
  Stopwatch := TStopwatch.StartNew;

  Lines := TFile.ReadAllLines('trades.jsonl');

  Stats := TDictionary<string, TSymbolStats>.Create;
  LockObj := TObject.Create;

  try

    TParallel.For(0, High(Lines),
      procedure(I: Integer)
      var
        Obj: TJSONObject;
        Symbol: string;
        Price: Double;
        Qty: Double;
        S: TSymbolStats;
      begin
        Obj := TJSONObject.ParseJSONValue(Lines[I]) as TJSONObject;

        try
          Symbol := Obj.GetValue<string>('symbol');
          Price := Obj.GetValue<Double>('price');
          Qty := Obj.GetValue<Double>('quantity');

          TMonitor.Enter(LockObj);
          try

            if not Stats.TryGetValue(Symbol, S) then
            begin
              S.Count := 0;
              S.Volume := 0;
              S.Value := 0;
              S.HighPrice := Price;
              S.LowPrice := Price;
            end;

            Inc(S.Count);

            S.Volume := S.Volume + Qty;
            S.Value := S.Value + (Price * Qty);

            if Price > S.HighPrice then
              S.HighPrice := Price;

            if Price < S.LowPrice then
              S.LowPrice := Price;

            Stats.AddOrSetValue(Symbol, S);

          finally
            TMonitor.Exit(LockObj);
          end;

        finally
          Obj.Free;
        end;
      end);

    Writeln;
    Writeln('Statistics');
    Writeln('----------');

    for var Pair in Stats do
    begin
      Writeln(
        Format(
          '%s  Trades=%d  Volume=%.2f  VWAP=%.2f',
          [
            Pair.Key,
            Pair.Value.Count,
            Pair.Value.Volume,
            Pair.Value.Value / Pair.Value.Volume
          ]
        ));
    end;

    Writeln;
    Writeln('Elapsed = ',
      Stopwatch.ElapsedMilliseconds,
      ' ms');

  finally
    Stats.Free;
    LockObj.Free;
  end;
end.
