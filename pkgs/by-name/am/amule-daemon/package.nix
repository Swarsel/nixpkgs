{
  amule,
  ...
}@args:

amule.override (
  {
    enableDaemon = true;
    mainProgram = "amuled";
    monolithic = false;
  }
  // removeAttrs args [ "amule" ]
)
