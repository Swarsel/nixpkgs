{
  lib,
  fetchFromGitHub,
  buildGoModule,
  nix-update-script,
  versionCheckHook,
  pkgsCross ? { },
}:

buildGoModule (finalAttrs: {
  pname = "ligolo-ng";
  version = "0.8.3";

  src = fetchFromGitHub {
    owner = "nicocha30";
    repo = "ligolo-ng";
    tag = "v${finalAttrs.version}";
    hash = "sha256-fh1TRJlF3NsLNLJBQXyA4if3goxPF1lYyPIaSOrawQM=";
  };

  vendorHash = "sha256-dOh8IRsluAy0vdHEXmevQxPCU33afNeuNPTq4Sxxb2g=";
  env.CGO_ENABLED = 0;
  # Tests require network access
  doCheck = false;

  # This will prefix all the binaries with ligolo-
  postInstall = ''
    for f in $out/bin/*; do
      mv "$f" "$(dirname "$f")/ligolo-$(basename "$f")"
    done
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  ldflags = [
    "-s"
    "-w"
    "-extldflags '-static'"
    "-X main.version=${finalAttrs.version}"
  ];

  subPackages = [
    "cmd/agent"
    "cmd/proxy"
  ];

  versionCheckProgram = "${placeholder "out"}/bin/ligolo-agent";

  passthru = {
    tests = {
      linux64 = pkgsCross.gnu64.ligolo-ng or null;
      win = pkgsCross.mingwW64.ligolo-ng or null;
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "Advanced TUN-based tunneling/pivoting tool";
    homepage = "https://github.com/nicocha30/ligolo-ng";
    changelog = "https://github.com/nicocha30/ligolo-ng/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ letgamer ];
    platforms = lib.platforms.linux ++ lib.platforms.windows;
  };
})
