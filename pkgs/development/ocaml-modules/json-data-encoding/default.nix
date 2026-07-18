{
  lib,
  fetchFromGitLab,
  buildDunePackage,
  hex,
  uri,
}:

buildDunePackage (finalAttrs: {
  pname = "json-data-encoding";
  version = "1.0.1";

  src = fetchFromGitLab {
    owner = "nomadic-labs";
    repo = "data-encoding";
    rev = "v${finalAttrs.version}";
    hash = "sha256-KoA4xX4tNyi6bX5kso/Wof1LA7431EXJ34eD5X4jnd8=";
  };

  propagatedBuildInputs = [
    hex
    uri
  ];

  minimalOCamlVersion = "4.10";

  meta = {
    description = "Type-safe encoding to and decoding from JSON";
    homepage = "https://gitlab.com/nomadic-labs/json-data-encoding";
    license = lib.licenses.lgpl3;
    maintainers = [ lib.maintainers.ulrikstrid ];
  };
})
