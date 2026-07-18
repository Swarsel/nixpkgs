{
  lib,
  fetchFromGitHub,
  cairo,
  glib,
  pango,
  pkg-config,
  rustPlatform,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "rofi-nerdy";
  version = "0.0.9";

  src = fetchFromGitHub {
    owner = "Rolv-Apneseth";
    repo = "rofi-nerdy";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FxMRUE4OKF0e1gNVFuEIGCbV83tUVj4ZNZFCjFqNb64=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    glib
    cairo
    pango
  ];

  cargoHash = "sha256-z7pfVLlOZFKxoqk87cHFd//DOArCvTpPK83UmJwmdtw=";

  postInstall = ''
    mkdir -p $out/lib/rofi
    mv $out/lib/librofi_nerdy.so $out/lib/rofi/nerdy.so
  '';

  meta = {
    description = "Nerd font icon selector plugin for rofi";
    homepage = "https://github.com/Rolv-Apneseth/rofi-nerdy";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ xavwe ];
    platforms = lib.platforms.linux;
  };
})
