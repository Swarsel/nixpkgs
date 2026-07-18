{
  lib,
  fetchFromGitHub,
  buildGoModule,
  gitMinimal,
  gitsign,
  makeWrapper,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "gitsign";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "sigstore";
    repo = "gitsign";
    rev = "v${finalAttrs.version}";
    hash = "sha256-BkaEI3YSnfMbRQ0r/rGUgZqUaCe3L1BXGxO4Ft19TdQ=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-Sltj/DwS3T7puIaH5HAZ+BE9vlv79+FlvK+t5O2VSM0=";
  nativeCheckInputs = [ gitMinimal ];

  preCheck = ''
    # test all paths
    unset subPackages
  '';

  postInstall = ''
    for f in $out/bin/*; do
      wrapProgram $f --prefix PATH : ${lib.makeBinPath [ gitMinimal ]}
    done
  '';

  ldflags = [
    "-s"
    "-w"
    "-X github.com/sigstore/gitsign/pkg/version.gitVersion=${finalAttrs.version}"
  ];

  subPackages = [
    "."
    "cmd/gitsign-credential-cache"
  ];

  passthru.tests.version = testers.testVersion { package = gitsign; };

  meta = {
    description = "Keyless Git signing using Sigstore";
    homepage = "https://github.com/sigstore/gitsign";
    changelog = "https://github.com/sigstore/gitsign/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      lesuisse
      developer-guy
    ];

    mainProgram = "gitsign";
  };
})
