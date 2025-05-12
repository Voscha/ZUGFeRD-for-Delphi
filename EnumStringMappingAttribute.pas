unit EnumStringMappingAttribute;

interface

type
  EnumStringValue = class(TCustomAttribute)
  private
    FAttrValue: string;
  public
    constructor Create(const Value: string);
    property AttrValue: string read FAttrValue;
  end;

implementation

{ EnumStringValue }

constructor EnumStringValue.Create(const Value: string);
begin
  inherited Create;
  FAttrValue := Value;
end;

end.
