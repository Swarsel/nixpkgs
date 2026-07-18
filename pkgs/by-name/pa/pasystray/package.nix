{
  lib,
  stdenv,
  fetchFromGitHub,
  adwaita-icon-theme,
  autoreconfHook,
  avahi,
  fetchpatch,
  gsettings-desktop-schemas,
  gtk3,
  libayatana-appindicator,
  libnotify,
  libpulseaudio,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "pasystray";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "christophgysin";
    repo = "pasystray";
    rev = finalAttrs.version;
    sha256 = "sha256-QaTQ8yUviJaFEQaQm2vYAUngqHliKe8TDYqfWt1Nx/0=";
  };

  patches = [
    # Use ayatana-appindicator instead of appindicator
    # https://github.com/christophgysin/pasystray/issues/98
    (fetchpatch {
      sha256 = "sha256-/HKPqVARfHr/3Vyls6a1n8ejxqW9Ztu4+8KK4jK8MkI=";
      url = "https://sources.debian.org/data/main/p/pasystray/0.8.1-1/debian/patches/0001-Build-against-ayatana-appindicator.patch";
    })
    # Require X11 backend
    # https://github.com/christophgysin/pasystray/issues/90#issuecomment-361881076
    (fetchpatch {
      sha256 = "sha256-6njC3vqBPWFS1xAsa1katQ4C0KJdVkHAP1MCPiZ6ELM=";
      url = "https://sources.debian.org/data/main/p/pasystray/0.8.1-1/debian/patches/0002-Require-X11-backend.patch";
    })
    # Fix build with GCC 15
    # https://github.com/christophgysin/pasystray/pull/183.patch
    (fetchpatch {
      hash = "sha256-BQ10LddqE3XwUeRklZE3S3+KOjJ9BtfddaFswgUqZ5g=";
      url = "https://github.com/christophgysin/pasystray/commit/9883809c7956471cf085ae90af4a9831c1234417.patch";
    })
  ];

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
    wrapGAppsHook3
  ];

  buildInputs = [
    adwaita-icon-theme
    avahi
    gtk3
    libayatana-appindicator
    libnotify
    libpulseaudio
    gsettings-desktop-schemas
  ];

  meta = {
    description = "PulseAudio system tray";
    homepage = "https://github.com/christophgysin/pasystray";
    license = lib.licenses.lgpl21Plus;

    maintainers = with lib.maintainers; [
      exlevan
      kamilchm
    ];

    platforms = lib.platforms.linux;
    mainProgram = "pasystray";
  };
})
