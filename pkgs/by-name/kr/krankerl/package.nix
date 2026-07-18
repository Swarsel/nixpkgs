{
  lib,
  fetchFromGitHub,
  dbus,
  file,
  makeWrapper,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "krankerl";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "ChristophWurst";
    repo = "krankerl";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-fFtjQFkNB5vn9nlFJI6nRdqxB9PmOGl3ySZ5LG2tgPg=";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    openssl
    dbus
    sqlite
  ];

  cargoHash = "sha256-tu+PJeGm8u5TSuoPBhaO4k6PkmI9JduuLlaQjvBv05E=";

  nativeCheckInputs = [
    file
  ];

  meta = {
    description = "CLI helper to manage, package and publish Nextcloud apps";
    homepage = "https://github.com/ChristophWurst/krankerl";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ onny ];
    platforms = lib.platforms.linux;
    mainProgram = "krankerl";
  };
})
