{
  lib,
  fetchFromGitHub,
  buildGoModule,
  versionCheckHook,
}:

let
  version = "0.17.94";
in
buildGoModule {
  inherit version;
  pname = "gqlgen";

  src = fetchFromGitHub {
    owner = "99designs";
    repo = "gqlgen";
    tag = "v${version}";
    hash = "sha256-dtApWhbuajgFlaDzNz2rvAQqz8x7YNnyeXyw/OqM5Qc=";
  };

  vendorHash = "sha256-n49MlAs6gWMxy6u/cH2UR3xd0iwttT3bTcOu2M0UFhc=";
  env.CGO_ENABLED = 0;

  checkFlags = [
    "-skip=^TestGenerate$" # skip tests that want to run `go mod tidy`
  ];

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  subPackages = [ "." ];
  versionCheckProgramArg = "version";

  meta = {
    description = "Go generate based GraphQL server library";
    homepage = "https://github.com/99designs/gqlgen";
    changelog = "https://github.com/99designs/gqlgen/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ skowalak ];
    mainProgram = "gqlgen";
  };
}
