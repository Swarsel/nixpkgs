{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "protozero";
  version = "1.8.2";

  src = fetchFromGitHub {
    owner = "mapbox";
    repo = "protozero";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pqRlSrCPBybKzKfXClGEIa8Pd1vS5vTpjIDhmz5UhYE=";
  };

  nativeBuildInputs = [ cmake ];

  meta = {
    description = "Minimalistic protocol buffer decoder and encoder in C++";
    homepage = "https://github.com/mapbox/protozero";

    changelog = [
      "https://github.com/mapbox/protozero/releases/tag/v${finalAttrs.version}"
      "https://github.com/mapbox/protozero/blob/v${finalAttrs.version}/CHANGELOG.md"
    ];

    license = with lib.licenses; [
      bsd2
      asl20
    ];

    maintainers = with lib.maintainers; [ das-g ];
    teams = [ lib.teams.geospatial ];
  };
})
