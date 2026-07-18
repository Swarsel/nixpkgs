{
  lib,
  stdenv,
  fetchFromCodeberg,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "mitra";
  version = "5.6.0";

  src = fetchFromCodeberg {
    owner = "silverpill";
    repo = "mitra";
    rev = "v${finalAttrs.version}";
    hash = "sha256-1G1XHLCdeETSqltrYxfxQCL4q1x7L2sqr9C2VOB9ecs=";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-VGJ1ObOe/QQzSwRov06hkf9zkrmSmODiJUkhC2+Bcrk=";

  env.RUSTFLAGS = toString [
    # MEMO: mitra use ammonia crate with unstable rustc flag
    "--cfg=ammonia_unstable"
  ];

  # require running database
  doCheck = false;

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd mitra \
      --bash <($out/bin/mitra completion --shell bash) \
      --fish <($out/bin/mitra completion --shell fish) \
      --zsh <($out/bin/mitra completion --shell zsh)
  '';

  buildFeatures = [
    "production"
  ];

  meta = {
    description = "Federated micro-blogging platform";
    homepage = "https://codeberg.org/silverpill/mitra";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ haruki7049 ];
    mainProgram = "mitra";
  };
})
