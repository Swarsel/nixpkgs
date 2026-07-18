{
  lib,
  stdenv,
  gcc,
  makeWrapper,
  requireFile,
  unzip,
}:

# v2.1: last version with NHM/WSM arch support
stdenv.mkDerivation rec {
  pname = "iaca";
  version = "2.1";

  src = requireFile {
    url = "https://software.intel.com/en-us/articles/intel-architecture-code-analyzer-download";
    sha256 = "11s1134ijf66wrc77ksky9mnb0lq6ml6fzmr86a6p6r5xclzay2m";
    name = "iaca-version-${version}-lin64.zip";
  };

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    mkdir -p $out/bin $out/lib
    cp bin/iaca $out/bin/
    cp lib/* $out/lib
  '';

  preFixup =
    let
      libPath = lib.makeLibraryPath [
        stdenv.cc.cc
        gcc
      ];
    in
    ''
      patchelf \
          --set-interpreter ${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 \
          --set-rpath $out/lib:"${libPath}" \
          $out/bin/iaca
    '';

  postFixup = "wrapProgram $out/bin/iaca --set LD_LIBRARY_PATH $out/lib";
  unpackCmd = ''${unzip}/bin/unzip "$src" -x __MACOSX/ __MACOSX/iaca-lin64/ __MACOSX/iaca-lin64/._.DS_Store'';

  meta = {
    description = "Intel Architecture Code Analyzer";
    homepage = "https://software.intel.com/en-us/articles/intel-architecture-code-analyzer/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ kazcw ];
    platforms = [ "x86_64-linux" ];
  };
}
