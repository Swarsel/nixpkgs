{
  amule,
  ...
}@args:

amule.override (
  {
    mainProgram = "amulecmd";
    monolithic = false;
    textClient = true;
  }
  // removeAttrs args [ "amule" ]
)
