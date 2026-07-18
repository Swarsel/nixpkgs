{
  amule,
  ...
}@args:

amule.override (
  {
    httpServer = true;
    mainProgram = "amuleweb";
    monolithic = false;
  }
  // removeAttrs args [ "amule" ]
)
