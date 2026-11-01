{
  InterfaceDemo

  Demonstrates Delphi interface reference counting using a simple
  console application.

  Topics Covered

  - Interface declarations
  - Interface GUIDs
  - _AddRef and _Release
  - Reference counting
  - Automatic object destruction
  - Scope-based lifetime management

  About Interfaces

  An interface defines a contract: a set of methods that a class must
  implement. Unlike ordinary object references, interface references are
  automatically managed through reference counting.

  Each time an interface reference is assigned, Delphi calls _AddRef to
  increase the reference count. When a reference goes out of scope or is
  set to nil, Delphi calls _Release to decrease the count.

  When the reference count reaches zero, the object automatically destroys
  itself. This removes the need to explicitly call Free and helps prevent
  memory leaks.

  References

  Free Pascal
    https://www.freepascal.org/docs-html/current/ref/refch7.html
    https://www.freepascal.org/docs-html/current/ref/refse51.html
    https://wiki.freepascal.org/Interfaces

  Delphi
    https://docwiki.embarcadero.com/RADStudio/Alexandria/en/Delphi_Interfaces
    https://docwiki.embarcadero.com/RADStudio/Florence/en/Interface_References

  Books
    Nick Hodges - Coding in Delphi
    Nick Hodges - More Coding in Delphi
    Marco Cantù - Object Pascal Handbook
}

program InterfaceDemo;

{$APPTYPE CONSOLE}
uses
  SysUtils;

type
  { Every COM-style interface has a GUID (Globally Unique Identifier).
    This uniquely identifies the interface at runtime and is used by
    mechanisms such as QueryInterface and Supports. It is not used for
    reference counting; that is handled by _AddRef and _Release. }

  IGreeter = interface
    ['{8154D532-D481-4C4A-84DC-BD4A8A469A11}']
    procedure SayHello;
  end;

  { Our greeter interface is a fairly contrived example, but the mechanism
  is exactly the same in your system. For example, iou might expose a logger,
  a database connection, a REST client, or some other service through
  an interface. As interface references come and go, Delphi keeps track
  of the reference count and automatically destroys the object when the
  last reference disappears.}


  {
    TDebugInterfacedObject class used only to observe reference counting
    in action. You would not use this is real life?
  }
  TDebugInterfacedObject = class(TInterfacedObject)
  protected
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  public
    constructor Create;
    destructor Destroy; override;
  end;

  {
    Our actual class and it implements the Greeter inteface and inherits
    from TInterfacedObject that provides the AddRef/Release code
  }
  TGreeter = class(TDebugInterfacedObject, IGreeter)
  public
    procedure SayHello;
  end;

{ **********************************************************************
  TDebugInterfacedObject
  *********************************************************************}

constructor TDebugInterfacedObject.Create;
begin
  inherited;
  Writeln(ClassName, '.Create');
end;

destructor TDebugInterfacedObject.Destroy;
begin
  Writeln(ClassName, '.Destroy');
  inherited;
end;

function TDebugInterfacedObject._AddRef: Integer;
begin
  Result := inherited _AddRef;
  Writeln(ClassName, '._AddRef  -> ', Result);
end;

function TDebugInterfacedObject._Release: Integer;
begin
  Result := inherited _Release;
  Writeln(ClassName, '._Release -> ', Result);
end;

{ **********************************************************************
  TGreeter
  *********************************************************************}

procedure TGreeter.SayHello;
begin
  Writeln('Hello from TGreeter');
end;

{ **********************************************************************
  Demos start here!
  *********************************************************************}


procedure SimpleDemo;
var
  A : IGreeter;
  B : IGreeter;
begin
  Writeln;
  Writeln('=== Create object ===');

  A := TGreeter.Create;

  Writeln;
  Writeln('=== Use object ===');
  A.SayHello;

  Writeln;
  Writeln('=== Copy interface reference ===');

  B := A;

  Writeln;
  Writeln('=== Clear B ===');

  B := nil;

  Writeln;
  Writeln('=== Clear A ===');

  //A := nil;

  {Notice that we never set A to nil, and we never called Free. Yet
  the object was still destroyed. Why? Because the interface variable went
  out of scope and Delphi automatically called _Release.}

end;

procedure ScopeDemo;
var
  G : IGreeter;
begin
  Writeln;
  Writeln('=== Scope Demo ===');

  G := TGreeter.Create;

  G.SayHello;

  Writeln('Leaving ScopeDemo...');
end;

begin
  try
    SimpleDemo;

    ScopeDemo;

    Writeln;
    Writeln('Back in main program');
    Readln;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
