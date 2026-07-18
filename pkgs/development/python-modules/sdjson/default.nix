{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  domdf-python-tools,
  typing-extensions,
  whey,
}:

buildPythonPackage rec {
  pname = "sdjson";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "domdfcoding";
    repo = "singledispatch-json";
    tag = "v${version}";
    hash = "sha256-7qwmPhij2X2GLtjeaoMCoOyT0qzYt9oFccWrQOq6LXw=";
  };

  # missing dependency coincidence
  doCheck = false;
  build-system = [ whey ];

  dependencies = [
    domdf-python-tools
    typing-extensions
  ];

  pyproject = true;
  pythonImportsCheck = [ "sdjson" ];

  meta = {
    description = "Custom JSON Encoder for Python utilising functools.singledispatch";
    homepage = "https://github.com/domdfcoding/singledispatch-json";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
}
