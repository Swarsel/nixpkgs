{
  lib,
  stdenv,
  fetchFromGitLab,
  kernel,
  kernelModuleMakeFlags,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "r8125";
  version = "9.016.01";

  src = fetchFromGitLab {
    owner = "debian";
    repo = "r8125";
    tag = "upstream/${finalAttrs.version}";
    hash = "sha256-Sg+f27nujBFtk0UxhVlc3c07MZVGVkEFAP5BH/NE0C4=";
    domain = "salsa.debian.org";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "BASEDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}"
  ];

  buildFlags = [ "modules" ];

  preBuild = ''
    substituteInPlace src/Makefile --replace-fail "BASEDIR :=" "BASEDIR ?="
    substituteInPlace src/Makefile --replace-fail "modules_install" "INSTALL_MOD_PATH=$out modules_install"
  '';

  installPhase = ''
    mkdir -p $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/ethernet/realtek
    cp src/r8125.ko $out/lib/modules/${kernel.modDirVersion}/kernel/drivers/net/ethernet/realtek/
  '';

  hardeningDisable = [ "pic" ];

  meta = {
    description = "Realtek r8125 2.5G Ethernet driver";
    homepage = "https://salsa.debian.org/debian/r8125";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.peelz ];
    platforms = lib.platforms.linux;
  };
})
