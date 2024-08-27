{* Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.}

unit TestBase;

interface

uses
    System.SysUtils;

type
  TTestBase = class
  protected
    function makeSurePathIsCrossPlatformCompatible(const path: string): string;
    procedure RandomizeByteArray(var A: TBytes);
  end;

implementation

uses System.IOUtils, System.Math;

{ TTestBase }

function TTestBase.makeSurePathIsCrossPlatformCompatible(const path: string): string;
begin
  if path.IsNullOrEmpty(path) then
    exit(path);
  result := path.Replace('\\', TPath.DirectorySeparatorChar);
end;

procedure TTestBase.RandomizeByteArray(var A: TBytes);
var
  I: Integer;
begin
  for I := 0 to High(A) do
  begin
    A[I] := RandomRange(Low(Byte), High(Byte) + 1);
  end;
end;

end.
