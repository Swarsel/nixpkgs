{
  lib,
  fetchFromGitHub,
  buildGoModule,
  carapace,
  nix-update-script,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "carapace";
  version = "1.7.1";

  src = fetchFromGitHub {
    owner = "carapace-sh";
    repo = "carapace-bin";
    tag = "v${finalAttrs.version}";
    hash = "sha256-wIRBz1WjN4Sy5hkRvAWHWRrtcTpVdY7BOLp1KF8UC5A=";
  };

  vendorHash = "sha256-s6Wq7+2S7hxAhU2OJ8TCkSG5H9dJjwlDy5G02Uqnzm4=";

  preBuild = ''
    GOOS= GOARCH= go generate ./...
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  proxyVendor = true;
  subPackages = [ "./cmd/carapace" ];
  tags = [ "release" ];
  passthru.tests.version = testers.testVersion { package = carapace; };
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Multi-shell multi-command argument completer";
    homepage = "https://carapace.sh/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mimame ];
    mainProgram = "carapace";
  };
})
