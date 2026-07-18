{
  lib,
  stdenv,
  fetchurl,
  alsa-lib,
  kernel,
}:

let
  bits = if stdenv.hostPlatform.is64bit then "64" else "32";

  libpath = lib.makeLibraryPath [
    stdenv.cc.cc
    stdenv.cc.libc
    alsa-lib
  ];

in
stdenv.mkDerivation rec {
  pname = "mwprocapture";
  version = "${subVersion}-${kernel.version}";

  src = fetchurl {
    url = "https://www.magewell.com/files/drivers/ProCaptureForLinux_${subVersion}.tar.gz";
    sha256 = "sha256-ZUqJkARhaMo9aZOtUMEdiHEbEq10lJO6MkGjEDnfx1g=";
  };

  nativeBuildInputs = kernel.moduleBuildDependencies;

  makeFlags = [
    "KERNELDIR=${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
  ];

  env.NIX_CFLAGS_COMPILE = "-Wno-error=implicit-fallthrough";

  preConfigure = ''
    cd ./src
    export INSTALL_MOD_PATH="$out"
  '';

  postInstall = ''
    cd ../
    mkdir -p $out/bin
    cp bin/mwcap-control_${bits} $out/bin/mwcap-control
    cp bin/mwcap-info_${bits} $out/bin/mwcap-info
    mkdir -p $out/lib/udev/rules.d
    # source has a filename typo
    cp scripts/10-procatpure-event-dev.rules $out/lib/udev/rules.d/10-procapture-event-dev.rules
    cp -r src/res $out

    patchelf \
      --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) \
      --set-rpath "${libpath}" \
      "$out"/bin/mwcap-control

    patchelf \
      --set-interpreter $(cat ${stdenv.cc}/nix-support/dynamic-linker) \
      --set-rpath "${libpath}" \
      "$out"/bin/mwcap-info
  '';

  hardeningDisable = [
    "pic"
    "format"
  ];

  subVersion = "1.3.4418";

  meta = {
    description = "Linux driver for the Magewell Pro Capture family";
    homepage = "https://www.magewell.com/";
    license = lib.licenses.unfreeRedistributable;
    maintainers = with lib.maintainers; [ flexiondotorg ];
    platforms = lib.platforms.linux;
    broken = lib.versionAtLeast kernel.version "6.15";
  };
}
