{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  fuse3,
  gitUpdater,
  icu,
  libzip,
  pandoc,
  pkg-config,
  versionCheckHook,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "mount-zip";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "google";
    repo = "mount-zip";
    rev = "v${finalAttrs.version}";
    hash = "sha256-z+WBELX+LUE749PEOIpWOHUtir7V7qOKagifQkIdgFk=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    pandoc
    pkg-config
  ];

  buildInputs = [
    boost
    fuse3
    icu
    libzip
  ];

  makeFlags = [ "PREFIX=$(out)" ];
  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru = {
    updateScript = gitUpdater { rev-prefix = "v"; };
  };

  meta = {
    description = "FUSE file system for ZIP archives";

    longDescription = ''
      mount-zip is a tool allowing to open, explore and extract ZIP archives.

      This project is a fork of fuse-zip.
    '';

    homepage = "https://github.com/google/mount-zip";
    changelog = "https://github.com/google/mount-zip/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      arti5an
      progrm_jarvis
    ];

    platforms = lib.platforms.linux;
    mainProgram = "mount-zip";
  };
})
