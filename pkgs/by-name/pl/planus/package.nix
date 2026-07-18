{
  lib,
  stdenv,
  fetchCrate,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "planus";
  version = "1.3.0";

  src = fetchCrate {
    inherit (finalAttrs) version;
    hash = "sha256-2ReR9cCB3kv1a9Ep60pshTI5B5jdimM0PBjvIOUdV5o=";
    pname = "planus-cli";
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  cargoHash = "sha256-0rDvYsEWEKDoPTCgeZ9Yxu1jc68LEzoS0BuzYsAdInQ=";

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    installShellCompletion --cmd planus \
      --bash <($out/bin/planus generate-completions bash) \
      --fish <($out/bin/planus generate-completions fish) \
      --zsh <($out/bin/planus generate-completions zsh)
  '';

  meta = {
    description = "Alternative compiler for flatbuffers";
    homepage = "https://github.com/planus-org/planus";
    changelog = "https://github.com/planus-org/planus/blob/v${finalAttrs.version}/CHANGELOG.md";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = [ ];
    mainProgram = "planus";
  };
})
