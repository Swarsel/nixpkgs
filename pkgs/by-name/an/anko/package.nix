{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "anko";
  version = "0.1.9";

  src = fetchFromGitHub {
    owner = "mattn";
    repo = "anko";
    tag = "v${finalAttrs.version}";
    hash = "sha256-ZVNkQu5IxBx3f+FkUWc36EOEcY176wQJ2ravLPQAHAA=";
  };

  vendorHash = null;
  __darwinAllowLocalNetworking = true;

  ldflags = [
    "-s"
    "-w"
  ];

  meta = {
    description = "Scriptable interpreter written in golang";
    homepage = "https://github.com/mattn/anko";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
