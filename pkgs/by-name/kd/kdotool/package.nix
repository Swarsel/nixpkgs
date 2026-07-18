{
  lib,
  fetchFromGitHub,
  dbus,
  fetchpatch,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kdotool";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "jinliu";
    repo = "kdotool";
    rev = "v${finalAttrs.version}";
    hash = "sha256-8lN85DPw3FUPS1k0Ktcp8Xf1DAdj6Hd6PqlKmhFCP+o=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ dbus ];
  cargoHash = "sha256-8WkLgTg+ndMtAh0W0efvRCDEgvhmKBcN0e0Jxn4hgH8=";

  meta = {
    description = "xdotool clone for KDE Wayland";
    homepage = "https://github.com/jinliu/kdotool";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ kotatsuyaki ];
  };
})
