ethercat:
{
  lib,
  stdenv,
  kernel,
  kernelModuleMakeFlags,
}:
let
  # Aside from a generic drivers there are special drivers for specific NICs
  # (for example r8139, r8169, e100, e1000, e1000e) which are only available
  # for these kernel versions
  extraSupportedKernel = lib.elem (lib.versions.majorMinor kernel.version) [
    "5.10"
    "5.14"
    "5.15"
    "6.1"
    "6.4"
    "6.12"
  ];
in
stdenv.mkDerivation {
  inherit (ethercat) src;
  pname = "ethercat";
  version = "${kernel.version}-${ethercat.version}";
  nativeBuildInputs = kernel.moduleBuildDependencies ++ ethercat.nativeBuildInputs;

  configureFlags = [
    "--with-linux-dir=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "--enable-userlib=no"
    "--enable-tool=no"
    "--enable-kernel=yes"
    "--enable-ccat=yes"
  ]
  ++ lib.optionals extraSupportedKernel [
    "--enable-e100=yes"
    "--enable-e1000=yes"
    "--enable-e1000e=yes"
    "--enable-r8169=yes"
    "--enable-igb=yes"
  ]
  ++ lib.optionals (extraSupportedKernel && lib.versionAtLeast kernel.version "5.14") [
    "--enable-igc=yes"
  ];

  makeFlags = kernelModuleMakeFlags ++ [
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  buildFlags = [ "modules" ];
  __structuredAttrs = true;
  enableParallelBuilding = true;
  installTargets = [ "modules_install" ];

  meta = {
    inherit (ethercat.meta)
      homepage
      changelog
      license
      maintainers
      platforms
      ;

    description = ethercat.meta.description + " - kernel modules";
  };
}
