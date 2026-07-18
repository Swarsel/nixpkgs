{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "carapace-bridge";
  version = "1.6.1";

  src = fetchFromGitHub {
    owner = "carapace-sh";
    repo = "carapace-bridge";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+PxsIkNRG9lwmhdzW/KB+CUkjJUXpYNn82m1tqIo/NE=";
  };

  postPatch = ''
    substituteInPlace cmd/carapace-bridge/main.go \
      --replace-fail "var version = \"develop\"" "var version = \"$version\""

    # Remove docker examples
    rm -r .docker
  '';

  vendorHash = "sha256-5d1LTwfYJe2RCNYNpKbO/3ofayTXDHD+OFul+wuXO0w=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  # buildGoModule tries to run `go mod vendor` instead of `go work vendor` on
  # the workspace if proxyVendor is off
  proxyVendor = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Multi-shell completion bridge for carapace";
    homepage = "https://carapace.sh/";
    changelog = "https://github.com/carapace-sh/carapace-bridge/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ famfo ];
    mainProgram = "carapace-bridge";
  };
})
