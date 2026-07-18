{
  lib,
  fetchFromGitHub,
  buildGoModule,
  testers,
  ticker,
}:

buildGoModule (finalAttrs: {
  pname = "ticker";
  version = "5.3.0";

  src = fetchFromGitHub {
    owner = "achannarasappa";
    repo = "ticker";
    tag = "v${finalAttrs.version}";
    hash = "sha256-DXaW1pL0MDM6GTm1i7ns94OgBqSsR94wFYoumOZsnXo=";
  };

  postPatch = ''
    substituteInPlace go.mod \
      --replace-fail "go 1.26.4" "go 1.26.3"
  '';

  vendorHash = "sha256-ulAmWbsLp5oiIRJNyI0jRXBGUnjRzkZt3zHdbxkCLV0=";
  # Tests require internet
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
    "-X github.com/achannarasappa/ticker/v${lib.versions.major finalAttrs.version}/cmd.Version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    inherit (finalAttrs) version;
    command = "ticker --version";
    package = ticker;
  };

  meta = {
    description = "Terminal stock ticker with live updates and position tracking";
    homepage = "https://github.com/achannarasappa/ticker";
    changelog = "https://github.com/achannarasappa/ticker/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      siraben
      sarcasticadmin
    ];

    mainProgram = "ticker";
  };
})
