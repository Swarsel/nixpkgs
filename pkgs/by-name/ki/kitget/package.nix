{
  lib,
  fetchFromCodeberg,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "kitget";
  version = "0.0.2";

  src = fetchFromCodeberg {
    owner = "koibtw";
    repo = "kitget";
    tag = "v${finalAttrs.version}";
    hash = "sha256-i26nu5SkcPhqwh+/bw1rz7h8K2u+hhSsOGiLj3sF1RQ=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-KARJV8SdbNa4tUuwyyfrLKdsj9fPF10MpL9hDGOQLm4=";
  # the project doesn't implement any tests
  doCheck = false;

  meta = {
    description = "Display and customize cat images in your terminal";
    homepage = "https://codeberg.org/koibtw/kitget";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ koi ];
    platforms = lib.platforms.linux;
    mainProgram = "kitget";
  };
})
