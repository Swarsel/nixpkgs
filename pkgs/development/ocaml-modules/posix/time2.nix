{
  lib,
  buildDunePackage,
  posix-base,
  posix-errno,
  posix-types,
}:

buildDunePackage {
  inherit (posix-base) version src;
  pname = "posix-time2";

  propagatedBuildInputs = [
    posix-base
    posix-types
    posix-errno
  ];

  doCheck = true;

  meta = posix-base.meta // {
    description = "Posix-time2 provides the types and bindings for posix time APIs";
    maintainers = with lib.maintainers; [ dandellion ];
  };
}
