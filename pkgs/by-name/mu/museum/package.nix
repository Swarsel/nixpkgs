{
  lib,
  fetchFromGitHub,
  buildGoModule,
  libsodium,
  nix-update-script,
  nixosTests,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "museum";
  version = "1.3.36";

  src = fetchFromGitHub {
    owner = "ente";
    repo = "ente";
    tag = "photos-v${finalAttrs.version}";
    hash = "sha256-9MWmJ3QUgS7BToTnSZzTi4ywGW1RtwrCO+9yQJkvejM=";
    sparseCheckout = [ "server" ];
  };

  nativeBuildInputs = [
    pkg-config
  ];

  buildInputs = [
    libsodium
  ];

  vendorHash = "sha256-qrcfNacMR2hwdtezwYrYTPpr1ALCwZktSW8UiyzGXjQ=";
  # fatal: "Not running tests in non-test environment"
  doCheck = false;

  postInstall = ''
    mkdir -p $out/share/museum
    cp -R configurations \
      migrations \
      mail-templates \
      web-templates \
      $out/share/museum
  '';

  sourceRoot = "${finalAttrs.src.name}/server";

  passthru = {
    tests.ente = nixosTests.ente;

    updateScript = nix-update-script {
      extraArgs = [
        "--version-regex"
        "photos-v(.*)"
      ];
    };
  };

  meta = {
    description = "API server for ente.io";
    homepage = "https://github.com/ente/ente/tree/main/server";
    changelog = "https://github.com/ente/ente/releases/tag/photos-v${finalAttrs.version}";
    license = lib.licenses.agpl3Only;

    maintainers = with lib.maintainers; [
      pinpox
      oddlama
      nicegamer7
    ];

    platforms = lib.platforms.linux;
    mainProgram = "museum";
  };
})
