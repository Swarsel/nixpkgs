{
  lib,
  stdenv,
  fetchFromGitHub,
  # nativeBuildInputs
  docbook_xml_dtd_45,
  docbook_xsl,
  gitUpdater,
  installShellFiles,
  libxslt,
  # buildInputs
  pcre,
  pkg-config,
  python3,
  versionCheckHook,
  which,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "cppcheck";
  version = "2.21.1";

  src = fetchFromGitHub {
    owner = "cppcheck-opensource";
    repo = "cppcheck";
    tag = finalAttrs.version;
    hash = "sha256-kpolGzSk+1lY8EXFciAimhUlv7we3bMbu2/Y0DlO4YU=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    substituteInPlace Makefile \
      --replace-fail 'PCRE_CONFIG = $(shell which pcre-config)' 'PCRE_CONFIG = $(PKG_CONFIG) libpcre'
  ''
  # Expected:
  # Internal Error. MathLib::toDoubleNumber: conversion failed: 1invalid
  #
  # Actual:
  # Internal Error. MathLib::toDoubleNumber: input was not completely consumed: 1invalid
  + lib.optionalString stdenv.hostPlatform.isDarwin ''
    substituteInPlace test/testmathlib.cpp \
      --replace-fail \
        'ASSERT_THROW_INTERNAL_EQUALS(MathLib::toDoubleNumber("1invalid"), INTERNAL, "Internal Error. MathLib::toDoubleNumber: conversion failed: 1invalid");' \
        "" \
      --replace-fail \
        'ASSERT_THROW_INTERNAL_EQUALS(MathLib::toDoubleNumber("1.1invalid"), INTERNAL, "Internal Error. MathLib::toDoubleNumber: conversion failed: 1.1invalid");' \
        ""
  '';

  strictDeps = true;

  nativeBuildInputs = [
    docbook_xml_dtd_45
    docbook_xsl
    installShellFiles
    libxslt
    pkg-config
    python3
    which
  ];

  buildInputs = [
    pcre
    (python3.withPackages (ps: [ ps.pygments ]))
  ];

  makeFlags = [
    "PREFIX=$(out)"
    "MATCHCOMPILER=yes"
    "FILESDIR=$(out)/share/cppcheck"
    "HAVE_RULES=yes"
  ];

  postBuild = ''
    make DB2MAN=${docbook_xsl}/xml/xsl/docbook/manpages/docbook.xsl man
  '';

  # test/testcondition.cpp:4949(TestCondition::alwaysTrueContainer): Assertion failed.
  doCheck = !(stdenv.hostPlatform.isLinux && stdenv.hostPlatform.isAarch64);

  postInstall = ''
    installManPage cppcheck.1
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  installCheckPhase = ''
    runHook preInstallCheck

    echo 'int main() {}' > ./installcheck.cpp
    $out/bin/cppcheck ./installcheck.cpp > /dev/null

    runHook postInstallCheck
  '';

  enableParallelBuilding = true;

  passthru = {
    updateScript = gitUpdater { };
  };

  meta = {
    description = "Static analysis tool for C/C++ code";

    longDescription = ''
      Check C/C++ code for memory leaks, mismatching allocation-deallocation,
      buffer overruns and more.
    '';

    homepage = "http://cppcheck.sourceforge.net";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ l33tname ];
    platforms = lib.platforms.unix;
  };
})
