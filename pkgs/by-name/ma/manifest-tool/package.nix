{
  lib,
  stdenv,
  fetchFromGitHub,
  buildGoModule,
  git,
  manifest-tool,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "manifest-tool";
  version = "2.2.1";

  src = fetchFromGitHub {
    owner = "estesp";
    repo = "manifest-tool";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3Vzeq81zLfJLV1XcnQLixL9+acjIegjspquvMsgtuXg=";
    leaveDotGit = true;

    postFetch = ''
      git -C $out rev-parse HEAD > $out/.git-revision
      rm -rf $out/.git
    '';
  };

  nativeBuildInputs = [ git ];
  vendorHash = null;

  preConfigure = ''
    export ldflags+=" -X main.gitCommit=$(cat .git-revision)"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ]
  ++ lib.optionals stdenv.hostPlatform.isStatic [
    "-linkmode=external"
    "-extldflags"
    "-static"
  ];

  modRoot = "v2";

  tags = lib.optionals stdenv.hostPlatform.isStatic [
    "cgo"
    "netgo"
    "osusergo"
    "static_build"
  ];

  passthru.tests.version = testers.testVersion {
    package = manifest-tool;
  };

  meta = {
    description = "Command line tool to create and query container image manifest list/indexes";
    homepage = "https://github.com/estesp/manifest-tool";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ tricktron ];
    mainProgram = "manifest-tool";
  };
})
