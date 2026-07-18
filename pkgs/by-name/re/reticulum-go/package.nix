{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
}:

buildGoModule (finalAttrs: {
  pname = "reticulum-go";
  version = "0.9.6";

  src = fetchFromGitHub {
    owner = "Quad4-Software";
    repo = "Reticulum-Go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Rji6MJQAN48zKsLHQS8ukbi9pWjHPEbezXJu/700HZs=";
  };

  # TODO: Remove this when https://github.com/NixOS/nixpkgs/pull/527289 has landed in `master`
  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "1.26.4" "1.26.3"
  '';

  strictDeps = true;
  vendorHash = null;
  # Required for some tests on darwin.
  __darwinAllowLocalNetworking = true;
  __structuredAttrs = true;

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "cmd/reticulum-go" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "High-performance Go implementation of the Reticulum Network Stack";
    homepage = "https://github.com/Quad4-Software/Reticulum-Go";
    changelog = "https://github.com/Quad4-Software/Reticulum-Go/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ drupol ];
    mainProgram = "reticulum-go";
  };
})
