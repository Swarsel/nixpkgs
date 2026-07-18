{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  glib,
  gtk4,
  jansson,
  libadwaita,
  libcotp,
  libgcrypt,
  libpng,
  libsecret,
  libuuid,
  pkg-config,
  protobufc,
  qrencode,
  wrapGAppsHook3,
  zbar,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "otpclient";
  version = "5.1.1";

  src = fetchFromGitHub {
    owner = "paolostivanin";
    repo = "otpclient";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sKXxujzHNQUZj9XloQLsZR12ZhyiY+512FOqgkTrxyQ=";
  };

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [
    gtk4
    glib
    libadwaita
    jansson
    libcotp
    libgcrypt
    libpng
    libsecret
    libuuid
    protobufc
    qrencode
    zbar
  ];

  __structuredAttrs = true;

  meta = {
    description = "Highly secure and easy to use OTP client written in C/GTK that supports both TOTP and HOTP";
    homepage = "https://github.com/paolostivanin/OTPClient";
    changelog = "https://github.com/paolostivanin/OTPClient/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ alexbakker ];
    platforms = lib.platforms.linux;
  };
})
