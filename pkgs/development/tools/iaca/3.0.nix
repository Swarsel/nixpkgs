{
  lib,
  stdenv,
  requireFile,
  unzip,
}:

stdenv.mkDerivation rec {
  pname = "iaca";
  version = "3.0";

  src = requireFile {
    url = "https://software.intel.com/en-us/articles/intel-architecture-code-analyzer-download";
    sha256 = "0qd81bxg269cwwvfmdp266kvhcl3sdvhrkfqdrbmanawk0w7lvp1";
    name = "iaca-version-v${version}-lin64.zip";
  };

  installPhase = ''
    mkdir -p $out/bin
    cp iaca $out/bin
    patchelf --set-interpreter ${stdenv.cc.libc}/lib/ld-linux-x86-64.so.2 $out/bin/iaca
  '';

  unpackCmd = ''${unzip}/bin/unzip "$src"'';

  meta = {
    description = "Intel Architecture Code Analyzer";
    homepage = "https://software.intel.com/en-us/articles/intel-architecture-code-analyzer/";
    license = lib.licenses.unfree;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    maintainers = with lib.maintainers; [ kazcw ];
    platforms = [ "x86_64-linux" ];
  };
}
