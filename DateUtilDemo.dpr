program DateUtilDemo;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Types,
  DateUtils;

var
  Date1, Date2,
  FutureDate,
  StartDate,
  EndDate: TDateTime;
  DaysCount: Integer;
  CompResult: TValueRelationship;
  CurrentMonth: Word;
begin
  try
    Writeln('========================================');
    Writeln('     System.DateUtils Demo Program      ');
    Writeln('========================================');
    Writeln;

    // 1. DaysBetween (Interval Calculations)
    Date1 := EncodeDate(2026, 1, 1);
    Date2 := EncodeDate(2026, 1, 15);
    DaysCount := DaysBetween(Date1, Date2);
    Writeln(Format('1. DaysBetween: Days between %s and %s = %d',
      [DateToStr(Date1), DateToStr(Date2), DaysCount]));

    // 2. IncMonth (Date Arithmetic)
    FutureDate := IncMonth(Date1, 3);
    Writeln(Format('2. IncMonth: 3 months after %s = %s',
      [DateToStr(Date1), DateToStr(FutureDate)]));

    // 3. CompareDate (Safe Comparisons)
    CompResult := CompareDate(Date1, Date2);
    if CompResult = LessThanValue then
      Writeln('3. CompareDate: Date1 is earlier than Date2')
    else if CompResult = GreaterThanValue then
      Writeln('3. CompareDate: Date1 is later than Date2')
    else
      Writeln('3. CompareDate: Dates are equal');

    // 4. StartOfAMonth / EndOfAMonth (Boundary Generators)
    StartDate := StartOfAMonth(2026, 11);
    EndDate := EndOfAMonth(2026, 11);
    Writeln(Format('4. Month Boundaries (November 2026):', []));
    Writeln(Format('   Start: %s', [DateTimeToStr(StartDate)]));
    Writeln(Format('   End:   %s', [DateTimeToStr(EndDate)]));

    // 5. MonthOf (Component Extractors)
    CurrentMonth := MonthOf(Now);
    Writeln(Format('5. MonthOf: The current month number is %d', [CurrentMonth]));

    Writeln;
    Writeln('========================================');
    Writeln('Press ENTER to exit...');
    ReadLn;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.

