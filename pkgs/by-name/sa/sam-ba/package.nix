{
  lib,
  stdenv,
  autoPatchelfHook,
  fetchzip,
  glib,
  libglvnd,
  python3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sam-ba";
  version = "3.5";

  src = fetchzip {
    url = "https://ww1.microchip.com/downloads/en/DeviceDoc/sam-ba_${finalAttrs.version}-linux_x86_64.tar.gz";
    sha256 = "1k0nbgyc98z94nphm2q7s82b274clfnayf4a2kv93l5594rzdbp1";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    glib
    libglvnd
    zlib

    (python3.withPackages (ps: [ ps.pyserial ]))
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/bin/" \
             "$out/opt/sam-ba/"
    cp -a . "$out/opt/sam-ba/"
    ln -sr "$out/opt/sam-ba/sam-ba" "$out/bin/"
    ln -sr "$out/opt/sam-ba/multi_sam-ba.py" "$out/bin/"

    runHook postInstall
  '';

  meta = {
    description = "Programming tools for Atmel SAM3/7/9 ARM-based microcontrollers";

    longDescription = ''
      Atmel SAM-BA software provides an open set of tools for programming the
      Atmel SAM3, SAM7 and SAM9 ARM-based microcontrollers.
    '';

    # Alternatively: https://www.microchip.com/en-us/development-tool/SAM-BA-In-system-Programmer
    homepage = "http://www.at91.com/linux4sam/bin/view/Linux4SAM/SoftwareTools";
    license = lib.licenses.gpl2Only;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ lib.maintainers.bjornfor ];
    platforms = [ "x86_64-linux" ];
  };
})
