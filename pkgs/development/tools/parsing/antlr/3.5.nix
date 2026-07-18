{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  fetchpatch,
  jre,
}:

stdenv.mkDerivation rec {
  inherit jre;
  pname = "antlr";
  version = "3.5.2";

  src = fetchFromGitHub {
    owner = "antlr";
    repo = "antlr3";
    rev = "5c2a916a10139cdb5c7c8851ee592ed9c3b3d4ff";
    sha256 = "1i0w2v9prrmczlwkfijfp4zfqfgrss90a7yk2hg3y0gkg2s4abbk";
  };

  patches = [
    (fetchpatch {
      sha256 = "0apk904afjqbad6c7z9r72a9lkbz69vwrl8j2a6zgxjn8dfb2p8b";
      url = "https://src.fedoraproject.org/rpms/antlr3/raw/f1bb8d639678047935e1761c3bf3c1c7da8d0f1d/f/0006-antlr3memory.hpp-fix-for-C-20-mode.patch";
    })
  ];

  installPhase = ''
    mkdir -p "$out"/{lib/antlr,bin,include}
    cp "$jar" "$out/lib/antlr/antlr-${version}-complete.jar"
    cp runtime/Cpp/include/* $out/include/

    echo "#! ${stdenv.shell}" >> "$out/bin/antlr"
    echo "'${jre}/bin/java' -cp '$out/lib/antlr/antlr-${version}-complete.jar' -Xms200M -Xmx400M org.antlr.Tool \"\$@\"" >> "$out/bin/antlr"

    chmod a+x "$out/bin/antlr"
    ln -s "$out/bin/antlr"{,3}
  '';

  jar = fetchurl {
    sha256 = "0srjwxipwsfzmpi0v32d1l5lzk9gi5in8ayg33sq8wyp8ygnbji6";
    url = "https://www.antlr3.org/download/antlr-${version}-complete.jar";
  };

  meta = {
    description = "Powerful parser generator";

    longDescription = ''
      ANTLR (ANother Tool for Language Recognition) is a powerful parser
      generator for reading, processing, executing, or translating structured
      text or binary files. It's widely used to build languages, tools, and
      frameworks. From a grammar, ANTLR generates a parser that can build and
      walk parse trees.
    '';

    homepage = "https://www.antlr.org/";
    license = lib.licenses.bsd3;
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = [ lib.maintainers.workflow ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
