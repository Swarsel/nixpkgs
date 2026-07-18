{
  lib,
  fetchFromGitHub,
  autoreconfHook,
  clangStdenv,
  git,
  libgeneral,
  libplist,
  lzfse,
  openssl,
  pkg-config,
}:
clangStdenv.mkDerivation (finalAttrs: {
  pname = "img4tool";
  version = "218";

  src = fetchFromGitHub {
    owner = "tihmstar";
    repo = "img4tool";
    tag = finalAttrs.version;
    hash = "sha256-s2pX+svCINI3EQsAlDKHm8P03/5C4MVA63wAwAH1lEs=";
  };

  # Do not depend on git to calculate version, instead
  # pass version via configureFlag
  patches = [ ./configure-version.patch ];
  strictDeps = true;

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    libgeneral
    libplist
    lzfse
    openssl
  ];

  configureFlags = [
    "--with-version-commit-count=${finalAttrs.version}"
  ];

  meta = {
    description = "Socket daemon to multiplex connections from and to iOS devices";
    homepage = "https://github.com/tihmstar/img4tool";
    license = lib.licenses.lgpl3;
    maintainers = with lib.maintainers; [ onny ];
    platforms = lib.platforms.linux;
    mainProgram = "img4tool";
  };
})
