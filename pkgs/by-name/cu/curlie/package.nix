{
  lib,
  fetchFromGitHub,
  buildGoModule,
  curlie,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "curlie";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "rs";
    repo = "curlie";
    tag = "v${finalAttrs.version}";
    hash = "sha256-BlpIDik4hkU4c+KCyAmgUURIN362RDQID/qo6Ojp2Ek=";
  };

  vendorHash = "sha256-GBccl8V87u26dtrGpHR+rKqRBqX6lq1SBwfsPvj/+44=";

  ldflags = [
    "-s"
    "-w"
    "-X main.version=${finalAttrs.version}"
  ];

  passthru.tests.version = testers.testVersion {
    command = "curlie version";
    package = curlie;
  };

  meta = {
    description = "Frontend to curl that adds the ease of use of httpie, without compromising on features and performance";
    homepage = "https://rs.github.io/curlie/";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ma27 ];
    mainProgram = "curlie";
  };
})
