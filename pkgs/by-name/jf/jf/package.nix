{
  lib,
  fetchFromGitHub,
  installShellFiles,
  rustPlatform,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname = "jf";
  version = "1.0.0";

  src = fetchFromGitHub {
    owner = "sayanarijit";
    repo = "jf";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GKAOM+YQicpPlCiecl4EgVDdvlHXP8j5txCodZVUKRg=";
  };

  nativeBuildInputs = [ installShellFiles ];
  cargoHash = "sha256-6fs3fhm0l24EZNZm3xXw8Uxb1Ot3pw+myfSJzWG3alU=";

  postInstall = ''
    installManPage assets/jf.1
  '';

  # skip auto manpage update
  buildNoDefaultFeatures = true;

  meta = {
    description = "Small utility to safely format and print JSON objects in the commandline";
    homepage = "https://github.com/sayanarijit/jf";
    license = lib.licenses.mit;
    maintainers = [ lib.maintainers.sayanarijit ];
    mainProgram = "jf";
  };
})
