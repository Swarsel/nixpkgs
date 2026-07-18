{
  lib,
  stdenv,
  fetchFromGitHub,
  clang,
  cmake,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "highs";
  version = "1.14.0";

  src = fetchFromGitHub {
    owner = "ERGO-Code";
    repo = "HiGHS";
    tag = "v${finalAttrs.version}";
    hash = "sha256-0KmA5B2g3AFCxMbN9gHdXxAEftZglhQKOqj1/TMxxps=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    clang
    cmake
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;
  enableParallelBuilding = true;

  meta = {
    description = "Linear optimization software";
    homepage = "https://github.com/ERGO-Code/HiGHS";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      galabovaa
      silky
    ];

    platforms = lib.platforms.all;
    mainProgram = "highs";
  };
})
