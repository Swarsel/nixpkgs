{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  fftwFloat,
  libsamplerate,
  pkg-config,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "csdr";
  version = "0.18.2";

  src = fetchFromGitHub {
    owner = "jketterl";
    repo = "csdr";
    rev = finalAttrs.version;
    sha256 = "sha256-LdVzeTTIvDQIXRdcz/vpQu/fUgtE8nx1kIEfoiwxrUg=";
  };

  postPatch = ''
    # function is not defined in any headers but used in libcsdr.c
    echo "int errhead();" >> src/predefined.h

    substituteInPlace CMakeLists.txt --replace-fail \
      "cmake_minimum_required (VERSION 3.0)" \
      "cmake_minimum_required (VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  propagatedBuildInputs = [
    fftwFloat
    libsamplerate
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  postFixup = ''
    substituteInPlace "$out"/lib/pkgconfig/csdr.pc \
      --replace '=''${prefix}//' '=/' \
      --replace '=''${exec_prefix}//' '=/'
  '';

  hardeningDisable = lib.optional stdenv.hostPlatform.isAarch64 "format";
  versionCheckProgramArg = "version";

  meta = {
    description = "Simple DSP library and command-line tool for Software Defined Radio";
    homepage = "https://github.com/jketterl/csdr";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.unix;
    broken = stdenv.hostPlatform.isDarwin;
  };
})
