{
  lib,
  stdenv,
  indi-3rdparty,
  indi-with-drivers,
  indilib,
}:

indi-with-drivers.override {
  inherit (indilib) version;
  pname = "indi-full-nonfree";

  extraDrivers = builtins.filter (attrs: lib.meta.availableOn stdenv.hostPlatform attrs) (
    builtins.attrValues indi-3rdparty
  );
}
