{ buildDunePackage, posix-base }:

buildDunePackage {
  inherit (posix-base) version src;
  pname = "posix-types";
  propagatedBuildInputs = [ posix-base ];

  meta = posix-base.meta // {
    description = "Bindings for the types defined in <sys/types.h>";
  };
}
