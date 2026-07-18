{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gossa";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "pldubouilh";
    repo = "gossa";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FGlUj0BJ8KeCfvdN9+NG4rqtaUIxgpqQ+09Ie1/TpAQ=";
    fetchSubmodules = true;
  };

  vendorHash = null;
  # Tests require a socket connection to be created.
  doCheck = false;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Fast and simple multimedia fileserver";
    homepage = "https://github.com/pldubouilh/gossa";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dsymbol ];
    mainProgram = "gossa";
  };
})
