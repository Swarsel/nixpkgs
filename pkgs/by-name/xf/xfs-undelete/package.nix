{
  lib,
  stdenv,
  fetchFromGitHub,
  coreutils,
  installShellFiles,
  makeWrapper,
  tcl-8_6,
  tclPackages,
}:

stdenv.mkDerivation {
  pname = "xfs_undelete";
  version = "unstable-2023-04-12";

  src = fetchFromGitHub {
    owner = "ianka";
    repo = "xfs_undelete";
    rev = "9e2f7abf0d3a466328e335d251c567ce4194e473";
    hash = "sha256-ENa/r3+o7abW8iun6V/2LhTVmFVSwVM6v46KXBcKJ1g=";
  };

  nativeBuildInputs = [
    makeWrapper
    tcl-8_6.tclPackageHook
    installShellFiles
  ];

  buildInputs = [
    tcl-8_6
    tclPackages.tcllib
    coreutils
  ];

  installPhase = ''
    runHook preInstall

    install -Dm555 xfs_undelete -t $out/bin
    mv xfs_undelete.man xfs_undelete.8
    installManPage xfs_undelete.8

    runHook postInstall
  '';

  tclWrapperArgs = [
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath [ tcl-8_6 ])
  ];

  meta = {
    description = "Undelete tool for the XFS filesystem";
    homepage = "https://github.com/ianka/xfs_undelete";
    license = lib.licenses.gpl3;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "xfs_undelete";
  };
}
