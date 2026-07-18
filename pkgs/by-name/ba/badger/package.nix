{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "badger";
  version = "4.9.3";

  src = fetchFromGitHub {
    owner = "dgraph-io";
    repo = "badger";
    tag = "v${finalAttrs.version}";
    hash = "sha256-B4DXzcgfkYcHqcK8F7NGbLcZWPmojMW4poRfCLv2DXI=";
  };

  vendorHash = "sha256-KDIwEH83nPMJPJGTN3UgO00pjYwR17XqGdPXioP1YcY=";
  doCheck = false;
  __structuredAttrs = true;
  subPackages = [ "badger" ];

  meta = {
    description = "Fast key-value DB in Go";
    homepage = "https://dgraph-io.github.io/badger";
    changelog = "https://github.com/dgraph-io/badger/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ hythera ];
    mainProgram = "badger";
  };
})
