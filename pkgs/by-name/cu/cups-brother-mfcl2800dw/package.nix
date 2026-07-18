{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  coreutils,
  dpkg,
  file,
  ghostscript,
  gnugrep,
  gnused,
  makeWrapper,
  perl,
  which,
}:
let
  arches = [
    "x86_64"
    "i686"
  ];
  version = "4.1.0-1";

  runtimeDeps = [
    ghostscript
    file
    gnused
    gnugrep
    coreutils
    which
  ];
in
stdenv.mkDerivation {
  inherit version;
  pname = "cups-brother-mfcl2800dw";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf106048/mfcl2800dwpdrv-${version}.i386.deb";
    hash = "sha256-sY92w0EFI69LxoNrhluIhqFOWZQOI+SJKKyuExvasgA=";
  };

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [ perl ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    dpkg-deb -x $src $out

    # delete unnecessary files for the current architecture
  ''
  + lib.concatMapStrings (arch: ''
    echo Deleting files for ${arch}
    rm -r "$out/opt/brother/Printers/MFCL2800DW/lpd/${arch}"
  '') (builtins.filter (arch: arch != stdenv.hostPlatform.linuxArch) arches)
  + ''

    # bundled scripts don't understand the arch subdirectories for some reason
    ln -s \
      "$out/opt/brother/Printers/MFCL2800DW/lpd/${stdenv.hostPlatform.linuxArch}/"* \
      "$out/opt/brother/Printers/MFCL2800DW/lpd/"

    # Fix global references and replace auto discovery mechanism with hardcoded values
    substituteInPlace $out/opt/brother/Printers/MFCL2800DW/lpd/lpdfilter \
      --replace-fail /opt "$out/opt" \
      --replace-fail "my \$BR_PRT_PATH =" "my \$BR_PRT_PATH = \"$out/opt/brother/Printers/MFCL2800DW\"; #" \
      --replace-fail "PRINTER =~" "PRINTER = \"MFCL2800DW\"; #"

    # Make sure all executables have the necessary runtime dependencies available
    find "$out" -executable -and -type f | while read file; do
      wrapProgram "$file" --prefix PATH : "${lib.makeBinPath runtimeDeps}"
    done

    # Symlink filter and ppd into a location where CUPS will discover it
    mkdir -p $out/lib/cups/filter $out/share/cups/model

    ln -s \
      $out/opt/brother/Printers/MFCL2800DW/lpd/lpdfilter \
      $out/lib/cups/filter/brother_lpdwrapper_MFCL2800DW

    ln -s \
      $out/opt/brother/Printers/MFCL2800DW/cupswrapper/brother-MFCL2800DW-cups-en.ppd \
      $out/share/cups/model/

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Brother MFC-L2750DW printer driver";
    homepage = "http://www.brother.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = [ lib.maintainers.luftmensch-luftmensch ];
    platforms = map (arch: "${arch}-linux") arches;
  };
}
