{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  bzip2,
  db,
  gcc14Stdenv,
  gpgme,
  libarchive,
  nix-update-script,
  versionCheckHook,
  xz,
  zlib,
}:

let
  theStdenv = if stdenv.isDarwin then gcc14Stdenv else stdenv;
in
theStdenv.mkDerivation (finalAttrs: {
  pname = "reprepro";
  version = "5.4.8";

  src = fetchFromGitLab {
    owner = "debian";
    repo = "reprepro";
    tag = "reprepro-${finalAttrs.version}";
    hash = "sha256-qHqRLWRbSwmpKkUQ8JenUo+CY91EY/h4yHHmq4TacMg=";
    domain = "salsa.debian.org";
  };

  nativeBuildInputs = [
    autoreconfHook
    versionCheckHook
  ];

  buildInputs = [
    bzip2
    db
    gpgme
    libarchive
    xz
    zlib
  ];

  doInstallCheck = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Debian package repository producer";
    homepage = "https://salsa.debian.org/debian/reprepro/";
    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ baloo ];
    platforms = lib.platforms.all;
    mainProgram = "reprepro";
  };
})
