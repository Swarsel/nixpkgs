{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:
let
  isKernelRT =
    (kernel.structuredExtraConfig ? PREEMPT_RT)
    && (kernel.structuredExtraConfig.PREEMPT_RT == lib.kernel.yes);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "lkrg";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "lkrg-org";
    repo = "lkrg";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Eb0+rgbI+gbY1NjVyPLB6kZgDsYoSCxjy162GophiMI=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNEL=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall
    install -D lkrg.ko $out/lib/modules/${kernel.modDirVersion}/extra/lkrg.ko
    runHook postInstall
  '';

  dontConfigure = true;
  enableParallelBuilding = true;
  hardeningDisable = [ "pic" ];
  name = "${finalAttrs.pname}-${finalAttrs.version}-${kernel.version}";

  prePatch = ''
    substituteInPlace Makefile --replace "KERNEL := " "KERNEL ?= "
  '';

  meta = {
    description = "LKRG Linux Kernel module";
    longDescription = "LKRG performs runtime integrity checking of the Linux kernel and detection of security vulnerability exploits against the kernel.";
    homepage = "https://lkrg.org/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ chivay ];
    platforms = lib.platforms.linux;
    broken = kernel.kernelOlder "5.10" || isKernelRT;
  };
})
