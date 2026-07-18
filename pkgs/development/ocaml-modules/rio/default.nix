{
  lib,
  fetchurl,
  buildDunePackage,
  cstruct,
}:

buildDunePackage (finalAttrs: {
  pname = "rio";
  version = "0.0.8";

  src = fetchurl {
    url = "https://github.com/leostera/riot/releases/download/${finalAttrs.version}/riot-${finalAttrs.version}.tbz";
    hash = "sha256-SsiDz53b9bMIT9Q3IwDdB3WKy98WSd9fiieU41qZpeE=";
  };

  propagatedBuildInputs = [
    cstruct
  ];

  minimalOCamlVersion = "5.1";

  meta = {
    description = "Ergonomic, composable, efficient read/write streams";
    homepage = "https://github.com/leostera/riot";
    changelog = "https://github.com/leostera/riot/blob/${finalAttrs.version}/CHANGES.md";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
