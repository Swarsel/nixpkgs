{
  lib,
  buildPythonPackage,
  docopt,
  fetchPypi,
  pygments,
  requests,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "clf";
  version = "0.5.7";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-q8kZoemWZ/Mv3eFd+0vFJ9viLPhqF6y3ikSdfy3+k34=";
  };

  # Error when running tests:
  # No local packages or download links found for requests
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    docopt
    requests
    pygments
  ];

  patchPhase = ''
    sed -i 's/==/>=/' requirements.txt
  '';

  pyproject = true;
  pythonImportsCheck = [ "clf" ];

  meta = {
    description = "Command line tool to search snippets on Commandlinefu.com";
    homepage = "https://github.com/ncrocfer/clf";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ koral ];
    mainProgram = "clf";
  };
})
