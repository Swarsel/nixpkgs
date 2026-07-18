{
  lib,
  fetchFromGitHub,
  buildGoModule,
  editorconfig-checker,
  installShellFiles,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "editorconfig-checker";
  version = "3.8.0";

  src = fetchFromGitHub {
    owner = "editorconfig-checker";
    repo = "editorconfig-checker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-t0EliFWYYxKfPbfLKP4p3wJvmIfXF6CPpWIgUuD3pXY=";
  };

  nativeBuildInputs = [ installShellFiles ];
  vendorHash = "sha256-5x7c8v+uMmqvyQnN47XgD8FFMoEq5/MPFO2WEj0WevU=";
  # Tests run on source and don't expect vendor dir.
  doCheck = false;

  postInstall = ''
    installManPage docs/editorconfig-checker.1
  '';

  ldflags = [ "-X main.version=${finalAttrs.version}" ];

  passthru.tests.version = testers.testVersion {
    package = editorconfig-checker;
  };

  meta = {
    description = "Tool to verify that your files are in harmony with your .editorconfig";
    homepage = "https://editorconfig-checker.github.io/";
    changelog = "https://github.com/editorconfig-checker/editorconfig-checker/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      zowoq
    ];

    mainProgram = "editorconfig-checker";
  };
})
