{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:
buildGoModule (finalAttrs: {
  pname = "quicktemplate";
  version = "1.8.0";

  src = fetchFromGitHub {
    owner = "valyala";
    repo = "quicktemplate";
    rev = "v${finalAttrs.version}";
    sha256 = "cra3LZ3Yq0KNQErQ2q0bVSy7rOLKdSkIryIgQsNRBHw=";
  };

  vendorHash = null;

  meta = {
    description = "Fast, powerful, yet easy to use template engine for Go";
    homepage = "https://github.com/valyala/quicktemplate";
    license = lib.licenses.mit;
    mainProgram = "qtc";
  };
})
