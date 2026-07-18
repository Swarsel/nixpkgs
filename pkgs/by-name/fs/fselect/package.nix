{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
  libiconv,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fselect";
  version = "0.10.2";

  src = fetchFromGitHub {
    owner = "jhspetersson";
    repo = "fselect";
    rev = finalAttrs.version;
    sha256 = "sha256-j9Md3yfL1tQkjCQ/Wo+oKaI/6OsJsCRsSscSiRuLOV0=";
  };

  nativeBuildInputs = [ installShellFiles ];
  buildInputs = lib.optional stdenv.hostPlatform.isDarwin libiconv;
  cargoHash = "sha256-+4dtpBcCOC1iwXKQHqgvvVtAvIFM3ZCAaefk9oPM1l0=";

  postInstall = ''
    installManPage docs/fselect.1
  '';

  meta = {
    description = "Find files with SQL-like queries";
    homepage = "https://github.com/jhspetersson/fselect";

    license = with lib.licenses; [
      asl20
      mit
    ];

    maintainers = with lib.maintainers; [
      matthiasbeyer
    ];

    mainProgram = "fselect";
  };
})
