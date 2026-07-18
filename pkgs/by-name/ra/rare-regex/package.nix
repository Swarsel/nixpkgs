{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  pcre2,
  rare-regex,
  testers,
  withPcre2 ? stdenv.hostPlatform.isLinux,
}:

buildGoModule (finalAttrs: {
  pname = "rare";
  version = "0.5.2";

  src = fetchFromGitHub {
    owner = "zix99";
    repo = "rare";
    tag = finalAttrs.version;
    hash = "sha256-tzAbt9THSTYDvooU7yNQJhJaFM1bcKCabDNtiMpux3Q=";
  };

  buildInputs = lib.optionals withPcre2 [
    pcre2
  ];

  vendorHash = "sha256-wUOtxNjL/4MosACCzPTWKWrnMZhxINfN1ppkRsqDh9M=";

  # Skip tests try /dev.
  checkFlags = [
    "-skip=TestNoMountTraverseWithSymlink"
  ];

  ldflags = [
    "-s"
    "-X=main.version=${finalAttrs.version}"
    "-X=main.buildSha=${finalAttrs.src.tag}"
  ];

  tags = lib.optionals withPcre2 [
    "pcre2"
  ];

  passthru.tests = {
    version = testers.testVersion {
      package = rare-regex;
    };
  };

  meta = {
    description = "Fast text scanner/regex extractor and realtime summarizer";
    homepage = "https://rare.zdyn.net";
    changelog = "https://github.com/zix99/rare/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ liberodark ];
    mainProgram = "rare";
  };
})
