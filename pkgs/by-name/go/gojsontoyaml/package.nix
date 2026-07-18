{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule (finalAttrs: {
  pname = "gojsontoyaml";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "brancz";
    repo = "gojsontoyaml";
    rev = "v${finalAttrs.version}";
    sha256 = "sha256-ebxz2uTH7XwD3j6JnsfET6aCGYjvsCjow/sU9pagg50=";
  };

  vendorHash = null;

  meta = {
    description = "Simply tool to convert json to yaml written in Go";
    homepage = "https://github.com/brancz/gojsontoyaml";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "gojsontoyaml";
  };
})
