{
  lib,
  stdenv,
  fetchFromGitHub,
  conceal,
  installShellFiles,
  rustPlatform,
  testers,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "conceal";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "TD-Sky";
    repo = "conceal";
    tag = "v${finalAttrs.version}";
    hash = "sha256-kPK00DjBHhyZVwCTuL3VSazS5pYY8lgLBn9bHTkaQ5s=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-6MPYgReVYkEQhmifzT7sAMRuMIink8k9nWOnSUCOGG0=";
  env.CONCEAL_GEN_COMPLETIONS = "true";
  # There are not any tests in source project.
  doCheck = false;

  postInstall = ''
    installShellCompletion \
      completions/{cnc/cnc,conceal/conceal}.{bash,fish} \
      --zsh completions/{cnc/_cnc,conceal/_conceal}
  '';

  passthru.tests = testers.testVersion {
    version = "conceal ${finalAttrs.version}";
    command = "conceal --version";
    package = conceal;
  };

  meta = {
    description = "Trash collector written in Rust";
    homepage = "https://github.com/TD-Sky/conceal";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      jedsek
      kashw2
    ];

    broken = stdenv.hostPlatform.isDarwin;
  };
})
