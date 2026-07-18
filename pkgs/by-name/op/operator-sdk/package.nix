{
  lib,
  fetchFromGitHub,
  buildGoModule,
  go,
  gpgme,
  makeWrapper,
  pkg-config,
}:

buildGoModule (finalAttrs: {
  pname = "operator-sdk";
  version = "1.42.3";

  src = fetchFromGitHub {
    owner = "operator-framework";
    repo = "operator-sdk";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DuNgesrqZvMoGHsi9wnVPHYvvSSEYi9FxAsSEhmlTZM=";
  };

  nativeBuildInputs = [
    makeWrapper
    pkg-config
  ];

  buildInputs = [
    go
    gpgme
  ];

  vendorHash = "sha256-FbLi+HoDsPIRoslSgMTJbb8bQ3F8pGMgOAnrSr0mGLQ=";
  doCheck = false;

  postFixup = ''
    wrapProgram $out/bin/operator-sdk --prefix PATH : ${lib.makeBinPath [ go ]}
  '';

  # operator-sdk uses the go compiler at runtime
  allowGoReference = true;

  subPackages = [
    "cmd/helm-operator"
    "cmd/operator-sdk"
  ];

  meta = {
    description = "SDK for building Kubernetes applications. Provides high level APIs, useful abstractions, and project scaffolding";
    homepage = "https://github.com/operator-framework/operator-sdk";
    changelog = "https://github.com/operator-framework/operator-sdk/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ arnarg ];
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
})
