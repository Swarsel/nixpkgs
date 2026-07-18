# Given a kernel build (with modules in $kernel/lib/modules/VERSION),
# produce a module tree in $out/lib/modules/VERSION that contains only
# the modules identified by `rootModules', plus their dependencies.
# Also generate an appropriate modules.dep.

{
  firmware,
  kernel,
  kmod,
  nukeReferences,
  rootModules,
  stdenvNoCC,
  allowMissing ? false,
  extraFirmwarePaths ? [ ],
}:

stdenvNoCC.mkDerivation {
  inherit
    kernel
    firmware
    rootModules
    allowMissing
    extraFirmwarePaths
    ;

  nativeBuildInputs = [
    nukeReferences
    kmod
  ];

  allowedReferences = [ "out" ];
  builder = ./modules-closure.sh;
  name = kernel.name + "-shrunk";
}
