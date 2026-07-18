{
  lib,
  stdenv,
  fetchurl,
  darwin,
  makeWrapper,
  testers,
  bootstrap-chicken ? null,
}:

let
  platform =
    with stdenv;
    if isDarwin then
      "macosx"
    else if isCygwin then
      "cygwin"
    else if (isFreeBSD || isOpenBSD) then
      "bsd"
    else if isSunOS then
      "solaris"
    else
      "linux"; # Should be a sane default
in
stdenv.mkDerivation (finalAttrs: {
  pname = "chicken";
  version = "5.4.0";

  src = fetchurl {
    url = "https://code.call-cc.org/releases/${finalAttrs.version}/chicken-${finalAttrs.version}.tar.gz";
    sha256 = "sha256-PF1KphwRZ79tm/nq+JHadjC6n188Fb8JUVpwOb/N7F8=";
  };

  # Disable two broken tests: "static link" and "linking tests"
  postPatch = ''
    sed -i tests/runtests.sh -e "/static link/,+4 { s/^/# / }"
    sed -i tests/runtests.sh -e "/linking tests/,+11 { s/^/# / }"
  '';

  nativeBuildInputs = [
    makeWrapper
  ]
  ++ lib.optionals (stdenv.hostPlatform.isDarwin && stdenv.hostPlatform.isAarch64) [
    darwin.autoSignDarwinBinariesHook
  ];

  buildInputs = lib.optionals (bootstrap-chicken != null) [
    bootstrap-chicken
  ];

  makeFlags = [
    "PLATFORM=${platform}"
    "PREFIX=$(out)"
    "C_COMPILER=$(CC)"
    "CXX_COMPILER=$(CXX)"
  ]
  ++ (lib.optionals stdenv.hostPlatform.isDarwin [
    "XCODE_TOOL_PATH=${darwin.binutils.bintools}/bin"
    "LINKER_OPTIONS=-headerpad_max_install_names"
    "POSTINSTALL_PROGRAM=install_name_tool"
  ])
  ++ (lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
    "HOSTSYSTEM=${stdenv.hostPlatform.config}"
    "TARGET_C_COMPILER=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}cc"
    "TARGET_CXX_COMPILER=${stdenv.cc}/bin/${stdenv.cc.targetPrefix}c++"
  ]);

  doCheck = !stdenv.hostPlatform.isDarwin;

  postCheck = ''
    ./csi -R chicken.pathname -R chicken.platform \
       -p "(assert (equal? \"${toString finalAttrs.binaryVersion}\" (pathname-file (car (repository-path)))))"
  '';

  binaryVersion = 11;
  setupHook = lib.optional (bootstrap-chicken != null) ./setup-hook.sh;

  passthru.tests.version = testers.testVersion {
    command = "csi -version";
    package = finalAttrs.finalPackage;
  };

  meta = {
    description = "Portable compiler for the Scheme programming language";

    longDescription = ''
      CHICKEN is a compiler for the Scheme programming language.
      CHICKEN produces portable and efficient C, supports almost all
      of the R5RS Scheme language standard, and includes many
      enhancements and extensions. CHICKEN runs on Linux, macOS,
      Windows, and many Unix flavours.
    '';

    homepage = "https://call-cc.org/";
    license = lib.licenses.bsd3;

    maintainers = with lib.maintainers; [
      corngood
      nagy
      konst-aa
    ];

    platforms = lib.platforms.unix;
  };
})
