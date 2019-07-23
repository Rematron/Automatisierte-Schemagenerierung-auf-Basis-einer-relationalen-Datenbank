//-----------------------------------
// Returns the error property, for occured errors (logs)
//-----------------------------------
function TBMDPpsXmlValidationGenerator.GetError: String;
begin
  Result := FError;
end;

//----------------------------------------
// Returns the status property, for http communication
//----------------------------------------
function TBMDPpsXmlValidationGenerator.GetStatus: String;
begin
  Result := FStatus;
end;

//----------------------------------------
// Returns the event method, for communication
//----------------------------------------
function TBMDPpsXmlValidationGenerator.GetDoDisplay: TBMDDoDisplayAbortEvent;
begin
  Result := FDoDisplay;
end;

//----------------------------------------
// Communication method, to display messages in the program
//----------------------------------------
function TBMDPpsXmlValidationGenerator.DisplayProgress(uDisplay: String): Boolean;
begin
  if Assigned(FDoDisplay) then begin
    Result := FDoDisplay(uDisplay);
  end
  else begin
    Result := TRUE;
  end;
end;