{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "kubernetes-metrics-server";
  version = "0.6.4";

  src = fetchFromGitHub {
    owner = "kubernetes-sigs";
    repo = "metrics-server";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-e9iFOe2iZaKbYNUk0vuyzcGDCNxot34kRH06L5UQs4I=";
  };

  vendorHash = "sha256-BR9mBBH5QE3FMTNtyHfHA1ei18CIDr5Yhvg28hGbDR4=";

  preCheck = ''
    # the e2e test breaks the sandbox, so let's skip that
    rm test/e2e_test.go
  '';

  meta = {
    description = "Kubernetes container resource metrics collector";
    homepage = "https://github.com/kubernetes-sigs/metrics-server";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ eskytthe ];
    mainProgram = "metrics-server";
  };
})
