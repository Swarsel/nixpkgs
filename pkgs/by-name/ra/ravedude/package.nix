{
  lib,
  stdenv,
  avrdude,
  fetchCrate,
  makeBinaryWrapper,
  nix-update-script,
  pkg-config,
  ravedude,
  rustPlatform,
  testers,
  udev,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "ravedude";
  version = "0.2.2";

  src = fetchCrate {
    inherit (finalAttrs) pname version;
    hash = "sha256-Ar2oQx7dKKfzkM3FMcJXiPHxNa0KcMRht38q+NgowfU=";
  };

  nativeBuildInputs = [
    pkg-config
    makeBinaryWrapper
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ udev ];
  cargoHash = "sha256-ME9egPOMTv/nEsmuxI+gJ6Tqa1Vqc/enlPttHXfTdBg=";

  postInstall = ''
    wrapProgram $out/bin/ravedude --suffix PATH : ${lib.makeBinPath [ avrdude ]}
  '';

  passthru = {
    tests.version = testers.testVersion {
      version = "v${finalAttrs.version}";
      package = ravedude;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Tool to easily flash code onto an AVR microcontroller with avrdude";
    homepage = "https://crates.io/crates/ravedude";

    license = with lib.licenses; [
      mit # or
      asl20
    ];

    maintainers = with lib.maintainers; [
      rvarago
      liff
    ];

    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    mainProgram = "ravedude";
  };
})
