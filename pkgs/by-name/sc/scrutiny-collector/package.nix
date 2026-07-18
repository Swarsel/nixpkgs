{
  lib,
  fetchFromGitHub,
  buildGoModule,
  makeWrapper,
  nix-update-script,
  nixosTests,
  smartmontools,
}:

buildGoModule (finalAttrs: {
  pname = "scrutiny-collector";
  version = "0.9.2";

  src = fetchFromGitHub {
    owner = "AnalogJ";
    repo = "scrutiny";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZQHTwJZBOYJ2De0CmyxXc4Fb2Vt+jKg+YpDDZhSt+cg=";
  };

  nativeBuildInputs = [ makeWrapper ];
  vendorHash = "sha256-Em8k2AFoZv4TD4HFkkNIdyPj7IBOFiUIKffkifWfZFY=";
  env.CGO_ENABLED = 0;

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp $GOPATH/bin/collector-metrics $out/bin/scrutiny-collector-metrics
    wrapProgram $out/bin/scrutiny-collector-metrics \
      --prefix PATH : ${lib.makeBinPath [ smartmontools ]}
    runHook postInstall
  '';

  ldflags = [ "-extldflags=-static" ];
  subPackages = "collector/cmd/collector-metrics";
  tags = [ "static" ];
  passthru.tests.scrutiny-collector = nixosTests.scrutiny;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Hard disk metrics collector for Scrutiny";
    homepage = "https://github.com/AnalogJ/scrutiny";
    changelog = "https://github.com/AnalogJ/scrutiny/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      samasaur
      svistoi
    ];

    mainProgram = "scrutiny-collector-metrics";
  };
})
