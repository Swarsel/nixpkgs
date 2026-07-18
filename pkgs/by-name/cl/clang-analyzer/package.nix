{
  lib,
  stdenv,
  clang,
  llvmPackages,
  makeWrapper,
  perl,
  python3,
}:

stdenv.mkDerivation {
  inherit (llvmPackages.clang-unwrapped) src version;
  pname = "clang-analyzer";
  patches = [ ./0001-Fix-scan-build-to-use-NIX_CFLAGS_COMPILE.patch ];
  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [
    clang
    llvmPackages.clang
    perl
    python3
  ];

  installPhase = ''
    mkdir -p $out/share/scan-view $out/bin
    cp -R clang/tools/scan-view/share/* $out/share/scan-view
    cp -R clang/tools/scan-view/bin/* $out/bin/scan-view
    cp -R clang/tools/scan-build/* $out

    rm $out/bin/*.bat $out/libexec/*.bat $out/CMakeLists.txt

    wrapProgram $out/bin/scan-build \
      --add-flags "--use-cc=${clang}/bin/clang" \
      --add-flags "--use-c++=${clang}/bin/clang++" \
      --add-flags "--use-analyzer='${llvmPackages.clang}/bin/clang'"
  '';

  dontBuild = true;

  meta = {
    description = "Clang Static Analyzer";

    longDescription = ''
      The Clang Static Analyzer is a source code analysis tool that finds bugs
      in C, C++, and Objective-C programs.
    '';

    homepage = "https://clang-analyzer.llvm.org/";
    license = lib.licenses.bsd3;
    maintainers = [ lib.maintainers.thoughtpolice ];
    platforms = lib.platforms.unix;
  };
}
