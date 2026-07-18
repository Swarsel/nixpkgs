{
  lib,
  stdenv,
  fetchurl,
  installShellFiles,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cmucl-binary";
  version = "21d";

  outputs = [
    "out"
    "doc"
    "man"
  ];

  nativeBuildInputs = [
    installShellFiles
  ];

  installPhase = ''
    runHook preInstall

    mkdir -pv $out $doc/share $man
    mv bin lib -t $out
    mv -v doc -t $doc/share
    installManPage man/man1/*

    runHook postInstall
  '';

  postFixup = ''
    patchelf --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
      $out/bin/lisp
  '';

  dontBuild = true;
  dontConfigure = true;
  sourceRoot = ".";

  srcs = [
    (fetchurl {
      hash = "sha256-RdctcqPTtQh1Yb3BrpQ8jtRFQn85OcwOt1l90H6xDZs=";

      url =
        "http://common-lisp.net/project/cmucl/downloads/release/"
        + finalAttrs.version
        + "/cmucl-${finalAttrs.version}-x86-linux.tar.bz2";
    })
    (fetchurl {
      hash = "sha256-zEmiW3m5VPpFgPxV1WJNCqgYRlHMovtaMXcgXyNukls=";

      url =
        "http://common-lisp.net/project/cmucl/downloads/release/"
        + finalAttrs.version
        + "/cmucl-${finalAttrs.version}-x86-linux.extra.tar.bz2";
    })
  ];

  meta = {
    description = "CMU implementation of Common Lisp";

    longDescription = ''
      CMUCL is a free implementation of the Common Lisp programming language
      which runs on most major Unix platforms.  It mainly conforms to the
      ANSI Common Lisp standard.
    '';

    homepage = "http://www.cons.org/cmucl/";
    license = lib.licenses.publicDomain;

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "lisp";
    teams = [ lib.teams.lisp ];
  };
})
