{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fetchpatch,
}:

buildGoModule (finalAttrs: {
  pname = "ffuf";
  version = "2.1.0";

  src = fetchFromGitHub {
    owner = "ffuf";
    repo = "ffuf";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+wcNqQHtB8yCLiJXMBxolCWsYZbBAsBGS1hs7j1lzUU=";
  };

  patches = [
    # Fix CSV test, https://github.com/ffuf/ffuf/pull/731
    (fetchpatch {
      hash = "sha256-/v9shGICmsbFfEJe4qBkBHB9PVbBlrjY3uFmODxHu9M=";
      name = "fix-csv-test.patch";
      url = "https://github.com/ffuf/ffuf/commit/7f2aae005ad73988a1fa13c1c33dab71f4ae5bbd.patch";
    })
  ];

  vendorHash = "sha256-SrC6Q7RKf+gwjJbxSZkWARw+kRtkwVv1UJshc/TkNdc=";

  ldflags = [
    "-w"
    "-s"
  ];

  meta = {
    description = "Tool for web fuzzing";

    longDescription = ''
      FFUF, or “Fuzz Faster you Fool” is an open source web fuzzing tool,
      intended for discovering elements and content within web applications
      or web servers.
    '';

    homepage = "https://github.com/ffuf/ffuf";
    changelog = "https://github.com/ffuf/ffuf/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "ffuf";
  };
})
