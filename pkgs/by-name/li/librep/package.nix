{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  fetchpatch,
  gdbm,
  gmp,
  libffi,
  pkg-config,
  readline,
  texinfo,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "librep";
  version = "0.92.7";

  src = fetchFromGitHub {
    owner = "SawfishWM";
    repo = "librep";
    tag = "librep-${finalAttrs.version}";
    hash = "sha256-0Ltysy+ilNhlXmvzSCMfF1n3x7F1idCRrhBFX/+n9uU=";
  };

  patches = [
    # build: fix -Wimplicit-int, -Wimplicit-function-declaration (Clang 16)
    (fetchpatch {
      hash = "sha256-MbFBNCgjEU1/QnjOe3uCWKVhpxo/E8c9q2TT3+CwPfY=";
      name = "fix-implicit-int";
      url = "https://github.com/SawfishWM/librep/commit/48f557ab34d47a7a1fd9e8425542f720be40946e.patch";
    })
  ];

  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
    texinfo
  ];

  buildInputs = [
    gdbm
    gmp
    libffi
    readline
  ];

  # ensure libsystem/ctype functions don't get duplicated when using clang
  configureFlags = lib.optionals stdenv.hostPlatform.isDarwin [ "CFLAGS=-std=gnu89" ];
  env.NIX_CFLAGS_COMPILE = "-Wno-error=incompatible-pointer-types";
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  enableParallelBuilding = true;
  setupHook = ./setup-hook.sh;
  versionCheckProgram = "${placeholder "out"}/bin/${finalAttrs.meta.mainProgram}";

  meta = {
    description = "Fast, lightweight, and versatile Lisp environment";

    longDescription = ''
      librep is a Lisp system for UNIX, comprising an interpreter, a byte-code
      compiler, and a virtual machine. It can serve as an application extension
      language but is also suitable for standalone scripts.
    '';

    homepage = "http://sawfish.tuxfamily.org/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "rep";
  };
})
