{
  lib,
  fetchFromGitHub,
  openssl,
  pkg-config,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "govee2mqtt";
  version = "2026.03.25-ab9deb66";

  src = fetchFromGitHub {
    owner = "wez";
    repo = "govee2mqtt";
    tag = finalAttrs.version;
    hash = "sha256-APGvE5BIYgZtAWbM9DGJFuGyI3715g8Gyxou8uhspdM=";
  };

  postPatch = ''
    substituteInPlace src/service/http.rs \
      --replace '"assets"' '"${placeholder "out"}/share/govee2mqtt/assets"'
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];
  cargoHash = "sha256-XIdWxhyARhAHV0IZXOHOl4mHFS5/4Is74B4615jYeDs=";

  postInstall = ''
    mkdir -p $out/share/govee2mqtt/
    cp -r assets $out/share/govee2mqtt/
  '';

  cargoPatches = [
    ./dont-vendor-openssl.diff
  ];

  meta = {
    description = "Connect Govee lights and devices to Home Assistant";
    homepage = "https://github.com/wez/govee2mqtt";
    changelog = "https://github.com/wez/govee2mqtt/blob/${finalAttrs.version}/addon/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      SuperSandro2000
      niklaskorz
    ];

    mainProgram = "govee";
  };
})
