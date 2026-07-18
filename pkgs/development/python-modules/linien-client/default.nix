{
  lib,
  buildPythonPackage,
  fabric,
  linien-common,
  numpy,
  scipy,
  setuptools,
  typing-extensions,
}:

buildPythonPackage rec {
  inherit (linien-common) src version;
  pname = "linien-client";

  preBuild = ''
    export HOME=$(mktemp -d)
  '';

  build-system = [ setuptools ];

  dependencies = [
    fabric
    typing-extensions
    numpy
    scipy
    linien-common
  ];

  pyproject = true;
  pythonImportsCheck = [ "linien_client" ];
  sourceRoot = "${src.name}/linien-client";

  meta = {
    description = "Client components of the Linien spectroscopy lock application";
    homepage = "https://github.com/linien-org/linien/tree/develop/linien-client";
    changelog = "https://github.com/linien-org/linien/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      fsagbuya
      doronbehar
    ];

    # See comment near linien-common.meta.broken
    broken = lib.versionAtLeast numpy.version "2";
  };
}
