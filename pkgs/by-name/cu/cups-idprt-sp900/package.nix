{
  lib,
  fetchurl,
  autoPatchelfHook,
  cups,
  e2fsprogs,
  krb5,
  libxcrypt-legacy,
  stdenvNoCC,
  unzip,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "cups-idprt-sp900";
  version = "1.4.0";

  src = fetchurl {
    url = "https://www.idprt.com/prt_v2/files/down_file/id/176/fid/498.html"; # NOTE: This is NOT an HTML page, but a ZIP file
    hash = "sha256-+YVQTrqpi16xX+d/ulMtffpA9X7hwtWRiS/mIAw13n8=";
    name = "idprt_sp900_printer_linux_driver.zip";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    unzip
  ];

  buildInputs = [
    cups
    e2fsprogs
    krb5
    libxcrypt-legacy
  ];

  installPhase =
    let
      arch =
        {
          x86-linux = "x86";
          x86_64-linux = "x64";
        }
        ."${stdenvNoCC.hostPlatform.system}"
          or (throw "cups-idprt-sp900: No prebuilt filters for system: ${stdenvNoCC.hostPlatform.system}");
    in
    ''
      runHook preInstall
      mkdir -p $out/share/cups/model $out/lib/cups/filter
      cp -r filter/${arch}/. $out/lib/cups/filter
      cp -r ppd/. $out/share/cups/model
      chmod +x $out/lib/cups/filter/*
      runHook postInstall
    '';

  sourceRoot = "idprt_sp900_printer_linux_driver_v${finalAttrs.version}/idprt_sp900_printer_linux_driver_v${finalAttrs.version}"; # >:|

  meta = {
    description = "CUPS driver for the iDPRT SP900";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ pandapip1 ];

    platforms = [
      "x86_64-linux"
      "x86-linux"
    ];
  };
})
