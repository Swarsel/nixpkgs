{
  lib,
  stdenv,
  fetchFromGitHub,
  gptman,
  libiconv,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "gptman";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "rust-disk-partition-management";
    repo = "gptman";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ebV61EilGggix6JSN/MW4Ka0itkSpvikLDSO005TTYY=";
  };

  buildInputs = lib.optional stdenv.hostPlatform.isDarwin libiconv;
  cargoHash = "sha256-v27tKdBPrtRwpNZRjyv8N7BpxOz6ZgFHaa5pe51YrTI=";
  buildFeatures = [ "cli" ];

  passthru.tests.version = testers.testVersion {
    package = gptman;
  };

  meta = {
    description = "GPT manager that allows you to copy partitions from one disk to another and more";
    homepage = "https://github.com/rust-disk-partition-management/gptman";

    license = with lib.licenses; [
      asl20 # or
      mit
    ];

    maintainers = with lib.maintainers; [ akshgpt7 ];
    mainProgram = "gptman";
  };
})
