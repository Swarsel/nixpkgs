{
  amule,
  ...
}@args:

amule.override (
  {
    client = true;
    mainProgram = "amulegui";
    monolithic = false;
  }
  // removeAttrs args [ "amule" ]
)
