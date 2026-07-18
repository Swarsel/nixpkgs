{
  lib,
  stdenv,
  fetchFromGitHub,
  buildNimPackage,
  git,
  makeWrapper,
  perl,
  perlPackages,
  which,
}:

buildNimPackage (finalAttrs: {
  pname = "taskopen";
  version = "2.0.3";

  src = fetchFromGitHub {
    owner = "jschlatow";
    repo = "taskopen";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-0SAiSaN9V1JYnyJsWda6unqUlyXRL8y8JHXP4VNAFhM=";
  };

  nativeBuildInputs = [ makeWrapper ];

  buildPhase = ''
    export HOME=$(pwd)
  '';

  installPhase = ''
    make PREFIX=$out install
  '';

  meta = {
    description = "Script for taking notes and open urls with taskwarrior";
    homepage = "https://github.com/ValiValpas/taskopen";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.winpat ];
    platforms = lib.platforms.all;
    mainProgram = "taskopen";
  };
})
