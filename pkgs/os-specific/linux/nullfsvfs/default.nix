{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  kernelModuleMakeFlags,
}:
stdenv.mkDerivation rec {
  pname = "nullfsvfs";
  version = "0.27";

  src = fetchFromGitHub {
    owner = "abbbi";
    repo = "nullfsvfs";
    rev = "v${version}";
    sha256 = "sha256-BvixSZN9GqFS4llaiKHfkLb21+qG74YtyNb8bUP0jdU=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = kernelModuleMakeFlags ++ [
    "KSRC=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/fs/nullfsvfs/"
    install -p -m 644 nullfsvfs.ko $out/lib/modules/${kernel.modDirVersion}/kernel/fs/nullfsvfs/
    runHook postInstall
  '';

  enableParallelBuilding = true;
  hardeningDisable = [ "pic" ];

  prePatch = ''
    substituteInPlace "Makefile" \
      --replace-fail "/lib/modules/\$(shell uname -r)/build" "\$(KSRC)"
  '';

  meta = {
    description = "Virtual black hole file system that behaves like /dev/null";
    homepage = "https://github.com/abbbi/nullfsvfs";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ callumio ];
    platforms = lib.platforms.linux;
  };
}
