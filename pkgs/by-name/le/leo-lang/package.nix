{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  versionCheckHook,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "leo-lang";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "ProvableHQ";
    repo = "leo";
    tag = "v${finalAttrs.version}";
    hash = "sha256-VDhD2devY2GPa2vGbZ0hSg1tIc6WJ5pgyDM6RsSb12U=";
    fetchSubmodules = true;
  };

  patches = [ ./0001-remove-update-subcommand.patch ];
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ] ++ lib.optionals stdenv.hostPlatform.isDarwin [ curl ];
  cargoHash = "sha256-PI2DviLVtlNFohRSOkGx7SQd2sh4jMKZKzw7RMKNw+o=";

  checkFlags = [
    "--skip=cli::cli::tests::nested_local_dependency_run_test"
    "--skip=cli::cli::tests::relaxed_shadowing_run_test"
    "--skip=cli::cli::tests::relaxed_struct_shadowing_run_test"
  ];

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  versionCheckProgram = "${placeholder "out"}/bin/leo";
  versionCheckProgramArg = "--version";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Functional, statically-typed programming language built for writing private applications";
    homepage = "https://github.com/ProvableHQ/leo";
    changelog = "https://github.com/ProvableHQ/leo/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ anstylian ];
    platforms = lib.platforms.unix;
    mainProgram = "leo";
  };
})
