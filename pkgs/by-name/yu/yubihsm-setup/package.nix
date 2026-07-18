{
  lib,
  fetchFromGitHub,
  fetchpatch,
  pkg-config,
  rustPlatform,
  yubihsm-shell,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "yubihsm-setup";
  version = "2.3.3";

  src = fetchFromGitHub {
    owner = "Yubico";
    repo = "yubihsm-setup";
    tag = finalAttrs.version;
    hash = "sha256-ScpcEDNWLhywtcPPG84vZyIAQ5lF07udmGsmsyc3+iU=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ yubihsm-shell ];
  cargoHash = "sha256-Mk0uGNb0WGygSqocpo566sVHs13zvoFBbAevJj4OSBM=";
  # https://github.com/Yubico/yubihsm-setup/pull/20
  cargoPatches = [ ./cargo-lock.patch ];

  prePatch = ''
    ln -s $yubihsmrs yubihsmrs
    substituteInPlace Cargo.toml --replace-fail ../yubihsmrs/ ./yubihsmrs/
  '';

  yubihsmrs = fetchFromGitHub {
    hash = "sha256-MQwp2dkAkPNyclDgRhHWRHZ9y4LC+bGIeLBv8CgMGXY=";
    owner = "Yubico";
    repo = "yubihsmrs";
    tag = "2.1.4";
  };

  meta = {
    description = "Tool to easily set up a YubiHSM device";
    homepage = "https://github.com/Yubico/yubihsm-setup";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      numinit
    ];

    platforms = lib.platforms.all;
  };
})
