{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "payme";
  version = "1.2.4";

  src = fetchFromGitHub {
    owner = "jovandeginste";
    repo = "payme";
    rev = "v${finalAttrs.version}";
    hash = "sha256-GXJjjCruDjL5+ag3aUJAHPLOvbwux9FBnyqXJ52WifE=";
    leaveDotGit = true;

    postFetch = ''
      cd "$out"
      git rev-parse HEAD > $out/COMMIT
      TZ=UTC0 git show --quiet --date=iso-local --format=%cd > $out/BUILD_TIME
      find "$out" -name .git -print0 | xargs -0 rm -rf
    '';
  };

  vendorHash = null;

  preBuild = ''
    ldflags+=" -X main.gitCommit=$(cat COMMIT)"
    ldflags+=" -X 'main.buildTime=$(cat BUILD_TIME)'"
  '';

  ldflags = [
    "-s"
    "-w"
    "-X main.gitRefName=${finalAttrs.src.rev}"
  ];

  meta = {
    description = "QR code generator (ASCII & PNG) for SEPA payments";
    homepage = "https://github.com/jovandeginste/payme";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cimm ];
    mainProgram = "payme";
  };
})
