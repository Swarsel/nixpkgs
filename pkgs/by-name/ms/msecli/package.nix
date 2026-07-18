{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  buildFHSEnv,
  zlib,
}:

let
  pname = "msecli";
  version = "10.01.012024.00";

  src = fetchurl {
    url = "https://web.archive.org/web/20240916144249/https://www.micron.com/content/dam/micron/global/public/products/software/storage-executive-software/msecli/msecli-linux.run";
    hash = "sha256-IszdD/9fAh+JA26bSR1roXSo8LDU/rf4CuRI3HjU1xc=";
  };

  buildEnv = buildFHSEnv {
    inherit version;
    pname = "msecli-buildEnv";
  };
in
stdenv.mkDerivation {
  inherit pname version src;
  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ zlib ];

  buildPhase = ''
    runHook preBuild

    # ignore the exit code as the installer
    # fails at optional steps due to read only FHS
    ${buildEnv}/bin/${buildEnv.pname} -c "./${src.name} --mode unattended --prefix bin || true"

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -v bin/msecli $out/bin

    runHook postInstall
  '';

  unpackPhase = ''
    runHook preUnpack

    cp "$src" ${src.name}
    chmod +x ${src.name}

    runHook postUnpack
  '';

  meta = {
    description = "Micron Storage Executive CLI";
    homepage = "https://www.micron.com/sales-support/downloads/software-drivers/storage-executive-software";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    maintainers = with lib.maintainers; [ diadatp ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "msecli";
  };
}
