{
  lib,
  fetchFromGitHub,
  buildGoModule,
  patch2pr,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "patch2pr";
  version = "0.45.1";

  src = fetchFromGitHub {
    owner = "bluekeyes";
    repo = "patch2pr";
    rev = "v${finalAttrs.version}";
    hash = "sha256-qzS2HslIAPY5cOoa2xc+uLzaSd9rcaBU7zAN4oFxh1A=";
  };

  vendorHash = "sha256-zziijcAoS5juDFAFM1p+B2N22YWt7dkjNktt5S6cj6k=";

  ldflags = [
    "-X main.version=${finalAttrs.version}"
    "-X main.commit=${finalAttrs.src.rev}"
  ];

  passthru.tests.patch2pr-version = testers.testVersion {
    version = finalAttrs.version;
    command = "${patch2pr.meta.mainProgram} --version";
    package = patch2pr;
  };

  meta = {
    description = "Create pull requests from patches without cloning the repository";
    homepage = "https://github.com/bluekeyes/patch2pr";
    changelog = "https://github.com/bluekeyes/patch2pr/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ katrinafyi ];
    mainProgram = "patch2pr";
  };
})
