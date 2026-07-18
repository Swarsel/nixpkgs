{
  lib,
  fetchFromGitLab,
  buildGo125Module,
  nix-update-script,
  versionCheckHook,
}:

buildGo125Module (finalAttrs: {
  pname = "sigsum";
  version = "0.14.1";

  src = fetchFromGitLab {
    owner = "core";
    repo = "sigsum-go";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZiU5eEI2pKknpjc3HU9EqQu6u1ZD/N7sOD0DyTma0/g=";
    domain = "git.glasklar.is";
    group = "sigsum";
  };

  postPatch = ''
    substituteInPlace internal/version/version.go \
      --replace-fail "info.Main.Version" '"${finalAttrs.version}"'
  '';

  vendorHash = "sha256-BaN9NslTvVyIp1Gi0N3UKdTXCd5opdL6Fb0AVoy9diM=";
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  excludedPackages = [ "./test" ];

  ldflags = [
    "-s"
    "-w"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/sigsum-key";

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--version-regex=^v(\\d+\\.\\d+\\.\\d+)$" ];
  };

  meta = {
    description = "System for public and transparent logging of signed checksums";
    homepage = "https://www.sigsum.org/";
    changelog = "https://git.glasklar.is/sigsum/core/sigsum-go/-/blob/v${finalAttrs.version}/NEWS";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ defelo ];
    downloadPage = "https://git.glasklar.is/sigsum/core/sigsum-go";
  };
})
