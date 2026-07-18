{
  lib,
  fetchFromGitHub,
  buildGoModule,
  kitex,
  testers,
}:

buildGoModule (finalAttrs: {
  pname = "kitex";
  version = "0.16.1";

  src = fetchFromGitHub {
    owner = "cloudwego";
    repo = "kitex";
    tag = "v${finalAttrs.version}";
    hash = "sha256-61VZ+eqAfxra5dEJ1MDwmLDuykEoVT07rPbMXcqZ/7o=";
  };

  vendorHash = "sha256-xsyfOuovG7LHcRMrtkT02DOp/L96M309QMiPLE24y9k=";

  postInstall = ''
    ln -s $out/bin/kitex $out/bin/protoc-gen-kitex
    ln -s $out/bin/kitex $out/bin/thrift-gen-kitex
  '';

  ldflags = [
    "-s"
    "-w"
  ];

  subPackages = [ "tool/cmd/kitex" ];

  passthru.tests.version = testers.testVersion {
    version = "v${finalAttrs.version}";
    package = kitex;
  };

  meta = {
    description = "High-performance and strong-extensibility Golang RPC framework";
    homepage = "https://github.com/cloudwego/kitex";
    license = lib.licenses.asl20;
    maintainers = [ ];
    mainProgram = "kitex";
  };
})
