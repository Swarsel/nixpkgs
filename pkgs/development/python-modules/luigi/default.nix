{
  lib,
  buildPythonPackage,
  fetchPypi,
  hatch-fancy-pypi-readme,
  hatchling,
  python-daemon,
  python-dateutil,
  tenacity,
  tornado,
  typing-extensions,
}:

buildPythonPackage (finalAttrs: {
  pname = "luigi";
  version = "3.8.1";

  src = fetchPypi {
    inherit (finalAttrs) version;
    hash = "sha256-L6XrXTR05JXeCb2WT1ApNsCPix624PPKPIppEWw40MM=";
    pname = "luigi";
  };

  # Requires tox, hadoop, and google cloud
  doCheck = false;

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    python-dateutil
    tornado
    python-daemon
    tenacity
    typing-extensions
  ];

  # This enables accessing modules stored in cwd
  makeWrapperArgs = [ "--prefix PYTHONPATH . :" ];
  pyproject = true;
  pythonImportsCheck = [ "luigi" ];
  pythonRelaxDeps = [ "tenacity" ];

  meta = {
    description = "Python package that helps you build complex pipelines of batch jobs";

    longDescription = ''
      Luigi handles dependency resolution, workflow management, visualization,
      handling failures, command line integration, and much more.
    '';

    homepage = "https://github.com/spotify/luigi";
    changelog = "https://github.com/spotify/luigi/releases/tag/${finalAttrs.version}";
    license = [ lib.licenses.asl20 ];
  };
})
