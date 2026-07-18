{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "kubectl-cnpg";
  version = "1.30.0";

  src = fetchFromGitHub {
    owner = "cloudnative-pg";
    repo = "cloudnative-pg";
    rev = "v${finalAttrs.version}";
    hash = "sha256-UHgllbD2eNBVYrF5nPZhethZIyyBkEji1xf0okGshoI=";
  };

  vendorHash = "sha256-Eh057tW8NTCNVtgyeY4A+Cc8wQbRDpUYDFmj4l+pn8o=";
  subPackages = [ "cmd/kubectl-cnpg" ];

  meta = {
    description = "Plugin for kubectl to manage a CloudNativePG cluster in Kubernetes";
    homepage = "https://cloudnative-pg.io/";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ devusb ];
    mainProgram = "kubectl-cnpg";
  };
})
