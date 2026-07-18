{
  lib,
  stdenv,
  fetchFromGitHub,
  dbus,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "music-discord-rpc";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "patryk-ku";
    repo = "music-discord-rpc";
    tag = "v${finalAttrs.version}";
    hash = "sha256-X2PIXP5W42ihT50BLApfULQxeUOAqDaNzn9tdxFir3A=";
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    dbus
    openssl
  ];

  cargoHash = "sha256-ROzRR1wQQNpweFcPzRnOMKjb6HTmViVbFR/zWugSYrU=";

  postInstall = ''
    mkdir --parents $out/etc/systemd/user
    substitute music-discord-rpc.service $out/etc/systemd/user/music-discord-rpc.service \
      --replace-fail /usr/bin/music-discord-rpc $out/bin/music-discord-rpc
  '';

  meta = {
    description = "Cross-platform Discord rich presence for music with album cover and progress bar support";
    homepage = "https://github.com/patryk-ku/music-discord-rpc";
    changelog = "https://github.com/patryk-ku/music-discord-rpc/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.lukaswrz ];
    mainProgram = "music-discord-rpc";
  };
})
