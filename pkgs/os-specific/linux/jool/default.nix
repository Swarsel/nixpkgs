{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchpatch,
  kernel,
  kernelModuleMakeFlags,
  nixosTests,
}:

let
  sourceAttrs = (import ./source.nix) { inherit fetchFromGitHub; };
in

stdenv.mkDerivation (finalAttrs: {
  inherit (sourceAttrs) version;
  pname = "jool";
  src = sourceAttrs.src;

  patches = lib.optionals (lib.versionAtLeast kernel.version "6.18.0") [
    (fetchpatch {
      hash = "sha256-EtV95YaOzPU3e/8NQvUtAH/RWiV16djeKrnvSgYybCQ=";
      url = "https://gitlab.alpinelinux.org/alpine/aports/-/raw/3.23-stable/community/jool-modules-lts/kernel-6.18.patch";
    })
  ];

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "-C src/mod"
    "INSTALL_MOD_PATH=${placeholder "out"}"
  ];

  hardeningDisable = [ "pic" ];
  installTargets = "modules_install";
  name = "${finalAttrs.pname}-${finalAttrs.version}-${kernel.version}";

  prePatch = ''
    sed -e 's@/lib/modules/\$(.*)@${kernel.dev}/lib/modules/${kernel.modDirVersion}@' -i src/mod/*/Makefile
  '';

  passthru.tests = {
    inherit (nixosTests) jool;
  };

  meta = {
    description = "Fairly compliant SIIT and Stateful NAT64 for Linux - kernel modules";
    homepage = "https://www.jool.mx/";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ fpletz ];
    platforms = lib.platforms.linux;
  };
})
