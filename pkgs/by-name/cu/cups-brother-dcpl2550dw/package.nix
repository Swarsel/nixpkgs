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
    "armv7l"
  ];

  runtimeDeps = [
    ghostscript
    file
    gnused
    gnugrep
    coreutils
    which
  ];
in

stdenv.mkDerivation rec {
  pname = "cups-brother-dcpl2550dw";
  version = "4.0.0-1";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103577/dcpl2550dwpdrv-${version}.i386.deb";
    hash = "sha256-gGW8KDXlmYSMxvI29pfXd/lusg4rd4HaXiGkbBnUuQY=";
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
    rm -r "$out/opt/brother/Printers/DCPL2550DW/lpd/${arch}"
  '') (builtins.filter (arch: arch != stdenv.hostPlatform.linuxArch) arches)
  + ''

    # bundled scripts don't understand the arch subdirectories for some reason
    ln -s \
      "$out/opt/brother/Printers/DCPL2550DW/lpd/${stdenv.hostPlatform.linuxArch}/"* \
      "$out/opt/brother/Printers/DCPL2550DW/lpd/"

    # Fix global references and replace auto discovery mechanism with hardcoded values
    substituteInPlace $out/opt/brother/Printers/DCPL2550DW/lpd/lpdfilter \
      --replace-fail /opt "$out/opt" \
      --replace-fail "my \$BR_PRT_PATH =" "my \$BR_PRT_PATH = \"$out/opt/brother/Printers/DCPL2550DW\"; #" \
      --replace-fail "PRINTER =~" "PRINTER = \"DCPL2550DW\"; #"

    # Make sure all executables have the necessary runtime dependencies available
    find "$out" -executable -and -type f | while read file; do
      wrapProgram "$file" --prefix PATH : "${lib.makeBinPath runtimeDeps}"
    done

    # Symlink filter and ppd into a location where CUPS will discover it
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/model

    ln -s \
      $out/opt/brother/Printers/DCPL2550DW/lpd/lpdfilter \
      $out/lib/cups/filter/brother_lpdwrapper_DCPL2550DW

    ln -s \
      $out/opt/brother/Printers/DCPL2550DW/cupswrapper/brother-DCPL2550DW-cups-en.ppd \
      $out/share/cups/model/

    runHook postInstall
  '';

  dontUnpack = true;

  meta = {
    description = "Brother DCP-L2550DW printer driver";
    homepage = "http://www.brother.com/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ typedrat ];
    platforms = map (arch: "${arch}-linux") arches;
    downloadPage = "https://support.brother.com/g/b/downloadlist.aspx?c=us&lang=en&prod=dcpl2550dw_us_as&os=128";
  };
}
