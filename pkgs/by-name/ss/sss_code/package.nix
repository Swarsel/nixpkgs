{
  lib,
  stdenv,
  fetchFromGitHub,
  fontconfig,
  libiconv,
  libxcb,
  oniguruma,
  pkg-config,
  rustPlatform,
  writableTmpDirAsHomeHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "sss_code";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "SergioRibera";
    repo = "sss";
    rev = "sss_code/v${finalAttrs.version}";
    hash = "sha256-AmJFAwHfG4R2iRz9zNeZsVFLptVy499ozQ7jgwnevOo=";
  };

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optionals stdenv.buildPlatform.isDarwin [
    libiconv
  ]
  ++ lib.optionals stdenv.cc.isClang [
    writableTmpDirAsHomeHook
  ];

  buildInputs = [
    fontconfig
    libxcb
    oniguruma
  ];

  cargoHash = "sha256-qeDZgrGPSz+wXolZeVb2FFHjLzl1+vjzMN/3NCgaf/s=";

  env = {
    RUSTONIG_SYSTEM_LIBONIG = true;
  };

  doCheck = false;

  cargoBuildFlags = [
    "-p"
    "sss_code"
  ];

  meta = {
    description = "Libraries and tools for building screenshots in a high-performance image format";
    homepage = "https://github.com/SergioRibera/sss";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [ krovuxdev ];
    mainProgram = "sss_code";
  };
})
