{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  avahi,
  cups,
  dpkg,
  patchPpdFilesHook,
  perl,
}:

stdenv.mkDerivation {
  pname = "lexmark-aex";
  version = "1.0";

  src = fetchurl {
    url = "https://downloads.lexmark.com/downloads/drivers/Lexmark-AEX-PPD-Files-1.0-01242019.amd64.deb";
    hash = "sha256-igrJEeFLArGbncOwk/WttnWfPjOokD0/IzpJ4VSOtHk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    autoPatchelfHook
    patchPpdFilesHook
    dpkg
  ];

  buildInputs = [
    # Needed for autoPatchelfHook.
    avahi
    cups
    # Needed for patchShebangs.
    perl
  ];

  installPhase =
    let
      libdir =
        if stdenv.system == "x86_64-linux" then
          "lib64"
        else if stdenv.system == "i686_linux" then
          "lib"
        else
          throw "other platforms than i686_linux and x86_64-linux are not yet supported";
    in
    ''
      runHook preInstall

      prefix=usr/local/Lexmark/ppd/Lexmark-AEX-PPD-Files/GlobalPPD_1.4

      # Install raster image filter.
      install -Dm755 "$prefix/rerouteprintoption" "$out/lib/cups/filter/rerouteprintoption"
      patchShebangs "$out/lib/cups/filter/rerouteprintoption"

      # Install additional binary filters.
      for i in CommandFileFilterG2 LexHBPFilter; do
        install -Dm755 "$prefix/${libdir}/$i" "$out/lib/cups/filter/$i"
      done

      # Install PPD.
      install -Dm 0644 -t "$out/share/cups/model/Lexmark" "$prefix"/*.ppd

      runHook postInstall
    '';

  dontPatchELF = true;
  dontStrip = true;

  ppdFileCommands = [
    "CommandFileFilterG2"
    "rerouteprintoption"
  ];

  # Needed for autoPatchelfHook.
  runtimeDependencies = [ (lib.getLib cups) ];

  meta = {
    description = "CUPS drivers for Lexmark B2200 and MB2200 Series printers";
    homepage = "https://support.lexmark.com/en_xm/drivers-downloads.html";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ lib.maintainers.tobim ];

    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}
