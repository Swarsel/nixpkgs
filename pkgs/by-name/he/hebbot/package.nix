{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  automake,
  cmake,
  openssl,
  pkg-config,
  rustPlatform,
  sqlite,
  unstableGitUpdater,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "hebbot";
  version = "2.1-unstable-2024-09-20";

  src = fetchFromGitHub {
    owner = "haecker-felix";
    repo = "hebbot";
    rev = "4c7152a3ce88ecfbac06f823abd4fd849e0c30d1";
    hash = "sha256-y+KpxiEzVAggFoPvTOy0IEmAo2V6mOpM0VzEScUOtsM=";
  };

  nativeBuildInputs = [
    pkg-config
    cmake
  ]
  ++ lib.optionals stdenv.hostPlatform.isDarwin [
    autoconf
    automake
  ];

  buildInputs = [
    openssl
  ];

  cargoHash = "sha256-xRTl6Z6sn44yaEIFxG2vVKlbruDmOS2CdPZeVmWYOoA=";

  env = {
    NIX_CFLAGS_LINK = toString [
      "-L${lib.getLib openssl}/lib"
      "-L${lib.getLib sqlite}/lib"
    ];

    OPENSSL_NO_VENDOR = 1;
  };

  passthru.updateScript = unstableGitUpdater { };

  meta = {
    description = "Matrix bot which can generate \"This Week in X\" like blog posts ";
    homepage = "https://github.com/haecker-felix/hebbot";
    changelog = "https://github.com/haecker-felix/hebbot/releases/tag/v2.1";
    license = with lib.licenses; [ agpl3Only ];
    maintainers = with lib.maintainers; [ a-kenji ];
    mainProgram = "hebbot";
  };
})
