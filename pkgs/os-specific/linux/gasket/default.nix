{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch2,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation {
  pname = "gasket";
  version = "1.0-18-unstable-2024-04-25";

  src = fetchFromGitHub {
    owner = "google";
    repo = "gasket-driver";
    rev = "5815ee3908a46a415aac616ac7b9aedcb98a504c";
    sha256 = "O17+msok1fY5tdX1DvqYVw6plkUDF25i8sqwd6mxYf8=";
  };

  patches = [
    (fetchpatch2 {
      hash = "sha256-UOoOSEnpUMa4QXWVFpGFxBoF5szXaLEfcWtfKatO5XY=";
      # https://github.com/google/gasket-driver/issues/36
      # https://github.com/google/gasket-driver/pull/35
      name = "linux-6.12-compat.patch";
      url = "https://github.com/google/gasket-driver/commit/4b2a1464f3b619daaf0f6c664c954a42c4b7ce00.patch";
    })
    (fetchpatch2 {
      hash = "sha256-roCo0/ETWuDVtZfbpFbrmy/icNI12A/ozOGQNLTtBUs=";
      # https://github.com/google/gasket-driver/issues/39
      # https://github.com/google/gasket-driver/pull/40
      name = "linux-6.13-compat.patch";
      url = "https://github.com/google/gasket-driver/commit/6fbf8f8f8bcbc0ac9c9bef7a56f495a2c9872652.patch";
    })
  ];

  postPatch = ''
    cd src
  '';

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "-C"
    "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
    "M=$(PWD)"
  ];

  buildFlags = [ "modules" ];

  hardeningDisable = [
    "pic"
    "format"
  ];

  installFlags = [ "INSTALL_MOD_PATH=${placeholder "out"}" ];
  installTargets = [ "modules_install" ];

  meta = {
    description = "Coral Gasket Driver allows usage of the Coral EdgeTPU on Linux systems";
    homepage = "https://github.com/google/gasket-driver";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.kylehendricks ];
    platforms = lib.platforms.linux;
    broken = lib.versionOlder kernel.version "5.15";
  };
}
