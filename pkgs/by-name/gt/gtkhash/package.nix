{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glib,
  gtk3,
  libb2,
  libgcrypt,
  meson,
  nettle,
  ninja,
  openssl,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gtkhash";
  version = "1.5";

  src = fetchFromGitHub {
    owner = "gtkhash";
    repo = "gtkhash";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XpgTolpTSsW3i0xk19tt4cn9qANoeiq7YnBBR6g8ioU=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    meson
    ninja
    cmake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk3
    glib
    openssl
    nettle
    libb2
    libgcrypt
  ];

  meta = {
    description = "Cross-platform desktop utility for computing message digests or checksums";
    homepage = "https://gtkhash.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ ByteSudoer ];
    platforms = lib.platforms.unix;
    mainProgram = "gtkhash";
  };
})
