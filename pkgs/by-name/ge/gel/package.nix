{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  # for passthru.tests:
  gel,
  makeBinaryWrapper,
  openssl,
  patchelf,
  pkg-config,
  replaceVars,
  rustPlatform,
  testers,
  xz,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gel";
  version = "7.10.2";

  src = fetchFromGitHub {
    owner = "geldata";
    repo = "gel-cli";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Fy4J7puunqB5TeUsafnOotoWNvtTGiMJZ06YII14zIM=";
  };

  patches = [
    (replaceVars ./0001-dynamically-patchelf-binaries.patch {
      inherit patchelf;
      dynamicLinker = stdenv.cc.bintools.dynamicLinker;
    })
  ];

  nativeBuildInputs = [
    makeBinaryWrapper
    pkg-config
  ];

  buildInputs = [
    curl
  ]
  ++ lib.optionals (!stdenv.hostPlatform.isDarwin) [
    openssl
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    xz
  ];

  env = {
    OPENSSL_NO_VENDOR = true;
  };

  doCheck = false;

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-VRZjI8C0u+6MkQgzt0PApeUtrGR5UqvnLZxityMGnDo=";
  };

  checkFeatures = [ ];

  passthru.tests.version = testers.testVersion {
    command = "gel --version";
    package = gel;
  };

  meta = {
    description = "Gel cli";
    homepage = "https://docs.geldata.com/reference/cli";
    changelog = "https://github.com/geldata/gel-cli/compare/v7.7.0...v7.10.2";

    license = with lib.licenses; [
      asl20
      # or
      mit
    ];

    maintainers = with lib.maintainers; [
      ahirner
      kirillrdy
    ];

    mainProgram = "gel";
  };
})
