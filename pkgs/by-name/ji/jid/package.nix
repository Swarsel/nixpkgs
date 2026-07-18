{
  lib,
  fetchFromGitHub,
  buildGoModule,
  jid,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "jid";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "simeji";
    repo = "jid";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Zf1YIEhvmvO482wh8VqQhyvHp7Nz6MXQ1SG0RCG0lRI=";
  };

  vendorHash = "sha256-ZqnIBmziPX45wqiEzD9mq4jLLW69mgGYhDSOTj20auQ=";

  ldflags = [
    "-s"
    "-w"
  ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = jid;
  };

  meta = {
    description = "Command-line tool to incrementally drill down JSON";
    homepage = "https://github.com/simeji/jid";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "jid";
  };
})
