{
  buildDunePackage,
  posix-base,
}:

buildDunePackage {
  inherit (posix-base) version src;
  pname = "posix-errno";

  propagatedBuildInputs = [
    posix-base
  ];

  doCheck = true;

  meta = posix-base.meta // {
    description = "Posix-errno provides comprehensive errno handling";
  };
}
