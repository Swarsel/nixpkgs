{
  buildDunePackage,
  ctypes,
  dune-configurator,
  libffi,
  lwt,
  ounit2,
}:

buildDunePackage {
  inherit (ctypes) version src doCheck;
  pname = "ctypes-foreign";
  buildInputs = [ dune-configurator ];

  propagatedBuildInputs = [
    ctypes
    libffi
  ];

  # Fix build with gcc 14
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";

  checkInputs = [
    ounit2
    lwt
  ];

  meta = ctypes.meta // {
    description = "Dynamic access to foreign C libraries using Ctypes";
  };
}
