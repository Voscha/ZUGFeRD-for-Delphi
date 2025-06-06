﻿{* Licensed to the Apache Software Foundation (ASF) under one
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

unit intf.ZUGFeRDSpecifiedProcuringProject;

interface

type
  /// <summary>
  /// Details about a project reference
  /// </summary>
  TZUGFeRDSpecifiedProcuringProject = class
  private
    FID: string;
    FName: string;
  public
    constructor CreateWithParams(const aID, aName: string);
    /// <summary>
    /// Project reference ID
    /// </summary>
    property ID: string read FID write FID;
    /// <summary>
    /// Project name
    /// </summary>
    property Name: string read FName write FName;
  end;

implementation


{ TZUGFeRDSpecifiedProcuringProject }

constructor TZUGFeRDSpecifiedProcuringProject.CreateWithParams(const aID, aName: string);
begin
  Create;
  FID := aID;
  FName := aName;
end;

end.
