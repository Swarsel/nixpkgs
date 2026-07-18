{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  buildPackages,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "zuo";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "racket";
    repo = "zuo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BUJtAKB2tz04LhkCsDWBjgTTymU4U3Zcdm+RDYawfxQ=";
  };

  strictDeps = true;
  nativeBuildInputs = [ autoreconfHook ];

  configureFlags = [
    "CC_FOR_BUILD=cc"
  ];

  doCheck = true;
  depsBuildBuild = [ buildPackages.stdenv.cc ];
  enableParallelBuilding = true;
  enableParallelChecking = true;

  meta = {
    description = "Tiny Racket for Scripting";
    homepage = "https://github.com/racket/zuo";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.RossSmyth ];
    platforms = lib.platforms.all;
    mainProgram = "zuo";
  };
})
