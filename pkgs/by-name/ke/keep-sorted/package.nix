{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
}:

buildGoModule (finalAttrs: {
  pname = "keep-sorted";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "keep-sorted";
    tag = "v${finalAttrs.version}";
    hash = "sha256-mp8Zr5K+PFRurEbOT/t7wlsmvfF9xUYho7MlFOO3BSU=";
  };

  # Inject version string instead of reading version from buildinfo.
  postPatch = ''
    substituteInPlace main.go \
      --replace-fail 'readVersion())' '"v${finalAttrs.version}")'
  '';

  vendorHash = "sha256-yocIoS0MknQt7Zz347W9bv63L1xaPBgkZOcpf0lhXBg=";
  env.CGO_ENABLED = "0";

  preCheck = ''
    # Test tries to find files using git in init func.
    rm goldens/*_test.go
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  ldflags = [ "-s" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Language-agnostic formatter that sorts lines between two markers in a larger file";
    homepage = "https://github.com/google/keep-sorted";
    changelog = "https://github.com/google/keep-sorted/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ katexochen ];
    mainProgram = "keep-sorted";
  };
})
