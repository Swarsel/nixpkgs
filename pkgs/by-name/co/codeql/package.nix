{
  lib,
  stdenv,
  curl,
  fetchzip,
  freetype,
  jdk17,
  libx11,
  libxext,
  libxi,
  libxrender,
  libxtst,
  zlib,
}:

stdenv.mkDerivation rec {
  pname = "codeql";
  version = "2.25.6";

  src = fetchzip {
    url = "https://github.com/github/codeql-cli-binaries/releases/download/v${version}/codeql.zip";
    hash = "sha256-1VLmiheNtN6EkPZfgP35hnAiIKhpnuFhigQd6W5DbxU=";
  };

  nativeBuildInputs = [
    zlib
    libx11
    libxext
    libxi
    libxtst
    libxrender
    freetype
    jdk17
    (lib.getLib stdenv.cc.cc)
    curl
  ];

  installPhase = ''
    # codeql directory should not be top-level, otherwise,
    # it'll include /nix/store to resolve extractors.
    mkdir -p $out/{codeql,bin}
    cp -R * $out/codeql/

    ln -sf $out/codeql/tools/linux64/lib64trace.so $out/codeql/tools/linux64/libtrace.so

    # many of the codeql extractors use CODEQL_DIST + CODEQL_PLATFORM to
    # resolve java home, so to be able to create databases, we want to make
    # sure that they point somewhere sane/usable since we can not autopatch
    # the codeql packaged java dist, but we DO want to patch the extractors
    # as well as the builders which are ELF binaries for the most part
    rm -rf $out/codeql/tools/linux64/java
    ln -s ${jdk17} $out/codeql/tools/linux64/java

    ln -s $out/codeql/codeql $out/bin/
  '';

  dontBuild = true;
  dontConfigure = true;
  dontStrip = true;

  meta = {
    description = "Semantic code analysis engine";
    homepage = "https://codeql.github.com";
    license = lib.licenses.unfree;
    maintainers = [ lib.maintainers.dump_stack ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
