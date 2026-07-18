{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-vcs,
  hatchling,
}:

buildPythonPackage (finalAttrs: {
  pname = "human-readable";
  version = "2.0.3";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-P4Ef1W7oZpVyyy7J+FK1PuBwB0jlPDaVcx/9mrT8Uks=";
    pname = "human_readable";
  };

  build-system = [
    hatchling
    hatch-vcs
  ];

  pyproject = true;
  pythonImportsCheck = [ "human_readable" ];

  meta = {
    description = "Library to make data intended for machines, readable to humans";
    homepage = "https://github.com/staticdev/human-readable";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ mkg20001 ];
  };
})
