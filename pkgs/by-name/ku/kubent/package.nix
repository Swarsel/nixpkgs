{
  lib,
  fetchFromGitHub,
  buildGoModule,
  kubent,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kubent";
  version = "0.7.3";

  src = fetchFromGitHub {
    owner = "doitintl";
    repo = "kube-no-trouble";
    rev = finalAttrs.version;
    hash = "sha256-7bn7DxbZ/Nqob7ZEWRy1UVg97FiJN5JWEgpH1CDz6jQ=";
  };

  vendorHash = "sha256-+V+/TK60V8NYUDfF5/EgSZg4CLBn6Mt57diiyXm179k=";

  ldflags = [
    "-w"
    "-s"
    "-X main.version=v${finalAttrs.version}"
  ];

  subPackages = [ "cmd/kubent" ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    command = "kubent --version";
    package = kubent;
  };

  meta = {
    description = "Easily check your cluster for use of deprecated APIs";
    homepage = "https://github.com/doitintl/kube-no-trouble";
    changelog = "https://github.com/doitintl/kube-no-trouble/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "kubent";
  };
})
