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
  pname = "cups-brother-hll2375dw";
  version = "4.0.0-1";

  src = fetchurl {
    url = "https://download.brother.com/welcome/dlf103535//hll2375dwpdrv-${version}.i386.deb";
    hash = "sha256-N5VCBZLFrfw29QjjzlSvQ12urvyaf7ez/RJ08UwqHdk=";
  };

  patches = [
    # The brother lpdwrapper uses a temporary file to convey the printer settings.
    # The original settings file will be copied with "400" permissions and the "brprintconflsr3"
    # binary cannot alter the temporary file later on. This fixes the permissions so the can be modified.
    # Since this is all in briefly in the temporary directory of systemd-cups and not accessible by others,
    # it shouldn't be a security concern.
    ./fix-perm.patch
  ];

  nativeBuildInputs = [
    dpkg
    makeWrapper
    autoPatchelfHook
  ];

  buildInputs = [ perl ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -ar opt $out/opt
    # delete unnecessary files for the current architecture
  ''
  + lib.concatMapStrings (arch: ''
    echo Deleting files for ${arch}
    rm -r "$out/opt/brother/Printers/HLL2375DW/lpd/${arch}"
  '') (builtins.filter (arch: arch != stdenv.hostPlatform.linuxArch) arches)
  + ''
    # bundled scripts don't understand the arch subdirectories for some reason
    ln -s \
      "$out/opt/brother/Printers/HLL2375DW/lpd/${stdenv.hostPlatform.linuxArch}/"* \
      "$out/opt/brother/Printers/HLL2375DW/lpd/"

    # Fix global references and replace auto discovery mechanism with hardcoded values
    substituteInPlace $out/opt/brother/Printers/HLL2375DW/lpd/lpdfilter \
      --replace "my \$BR_PRT_PATH =" "my \$BR_PRT_PATH = \"$out/opt/brother/Printers/HLL2375DW\"; #" \
      --replace "PRINTER =~" "PRINTER = \"HLL2375DW\"; #"
    substituteInPlace $out/opt/brother/Printers/HLL2375DW/cupswrapper/lpdwrapper \
      --replace "my \$basedir = C" "my \$basedir = \"$out/opt/brother/Printers/HLL2375DW\" ; #" \
      --replace "PRINTER =~" "PRINTER = \"HLL2375DW\"; #"

    # Make sure all executables have the necessary runtime dependencies available
    find "$out" -executable -and -type f | while read file; do
      wrapProgram "$file" --prefix PATH : "${lib.makeBinPath runtimeDeps}"
    done

    # Symlink filter and ppd into a location where CUPS will discover it
    mkdir -p $out/lib/cups/filter
    mkdir -p $out/share/cups/model
    mkdir -p $out/etc/opt/brother/Printers/HLL2375DW/inf

    ln -s $out/opt/brother/Printers/HLL2375DW/inf/brHLL2375DWrc \
          $out/etc/opt/brother/Printers/HLL2375DW/inf/brHLL2375DWrc
    ln -s \
      $out/opt/brother/Printers/HLL2375DW/cupswrapper/lpdwrapper \
      $out/lib/cups/filter/brother_lpdwrapper_HLL2375DW
    ln -s \
      $out/opt/brother/Printers/HLL2375DW/cupswrapper/brother-HLL2375DW-cups-en.ppd \
      $out/share/cups/model/
    runHook postInstall
  '';

  meta = {
    description = "Brother HLL2375DW printer driver";
    homepage = "http://www.brother.com/";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.gador ];
    platforms = map (arch: "${arch}-linux") arches;
  };
}
