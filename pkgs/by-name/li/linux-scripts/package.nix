{
  lib,
  binutils,
  # decompressors for possible kernel image formats
  bzip2,
  coreutils,
  gnugrep,
  gzip,
  linuxHeaders, # Linux source tree
  lz4,
  lzop,
  makeWrapper,
  stdenvNoCC,
  xz,
  zstd,
}:

let
  commonDeps = [
    binutils
    coreutils
    gnugrep
    gzip
    xz
    bzip2
    lzop
    lz4
    zstd
  ];

  toWrapScriptLines = scriptName: ''
    install -Dm 0755 scripts/${scriptName} $out/bin/${scriptName}
    wrapProgram $out/bin/${scriptName} --prefix PATH : ${lib.makeBinPath commonDeps}
  '';
in
stdenvNoCC.mkDerivation {
  inherit (linuxHeaders) version;
  pname = "linux-scripts";
  # These scripts will rarely change and are usually not bound to a specific
  # version of Linux. So it is okay to just use whatever Linux version comes
  # from `linuxHeaders.
  src = linuxHeaders.src;
  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    ${toWrapScriptLines "extract-ikconfig"}
    ${toWrapScriptLines "extract-vmlinux"}
  '';

  dontBuild = true;
  dontConfigure = true;

  meta = {
    description = "Standalone scripts from <linux>/scripts";
    homepage = "https://www.kernel.org/";
    license = lib.licenses.gpl2Only;
    maintainers = [ lib.maintainers.phip1611 ];
    platforms = lib.platforms.all;
  };
}
