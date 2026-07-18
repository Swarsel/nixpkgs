{
  lib,
  fetchFromGitHub,
  buildDunePackage,
  yojson,
}:

buildDunePackage (finalAttrs: {
  pname = "ppx_yojson_conv_lib";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "janestreet";
    repo = "ppx_yojson_conv_lib";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XGgpcAEemBNEagblBjpK+BiL0OUsU2JPqOq+heHbqVk=";
  };

  propagatedBuildInputs = [ yojson ];
  minimalOCamlVersion = "4.02.3";

  meta = {
    description = "Runtime lib for ppx_yojson_conv";
    homepage = "https://github.com/janestreet/ppx_yojson_conv_lib";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
