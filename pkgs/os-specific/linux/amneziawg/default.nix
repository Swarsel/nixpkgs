{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
  nix-update-script,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "amneziawg";
  version = "1.0.20260611";

  src = fetchFromGitHub {
    owner = "amnezia-vpn";
    repo = "amneziawg-linux-kernel-module";
    tag = "v${finalAttrs.version}";
    hash = "sha256-eMApc7VHWB1GL8YWdAS7HyEgkV/nkLjwBMOP+gtuHOE=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  buildFlags = [
    "module"
  ];

  enableParallelBuilding = true;
  hardeningDisable = [ "pic" ];

  installFlags = [
    "DEPMOD=true"
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  sourceRoot = "${finalAttrs.src.name}/src";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Kernel module for the AmneziaWG";
    homepage = "https://amnezia.org";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ averyanalex ];
    platforms = lib.platforms.linux;
  };
})
