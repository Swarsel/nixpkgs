{
  buildDunePackage,
  posix-base,
}:

buildDunePackage {
  inherit (posix-base) src version;
  pname = "posix-math2";

  propagatedBuildInputs = [
    posix-base
  ];

  meta = posix-base.meta // {
    description = "Bindings for posix math";
  };
}
