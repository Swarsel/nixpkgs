{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  jinja2,
  jsonschema,
  poetry-core,
  pytest7CheckHook,
  pyyaml,
  termcolor,
}:

buildPythonPackage rec {
  pname = "barectf";
  version = "3.1.2";

  src = fetchFromGitHub {
    owner = "efficios";
    repo = "barectf";
    rev = "v${version}";
    hash = "sha256-JelFfd3WS012dveNlIljhLdyPmgE9VEOXoZE3MBA/Gw=";
  };

  patches = [
    (fetchpatch {
      excludes = [
        "pyproject.toml"
        "poetry.lock"
      ];

      hash = "sha256-5tSOxc6trSHFPnVj+7YVO9J65bZ1H2MFKrZAbRy1WTM=";
      name = "setuptools-82-compat.patch";
      url = "https://github.com/efficios/barectf/commit/e16d289546bb4f6b0d909f79b8d6188eabe32640.patch";
    })
  ];

  nativeBuildInputs = [
    poetry-core
  ];

  propagatedBuildInputs = [
    jsonschema
    pyyaml
    jinja2
    termcolor
  ];

  nativeCheckInputs = [ pytest7CheckHook ];
  pyproject = true;
  pythonImportsCheck = [ "barectf" ];

  pythonRelaxDeps = [
    "jsonschema"
    "pyyaml"
    "termcolor"
  ];

  pythonRemoveDeps = [
    "setuptools"
  ];

  meta = {
    description = "Generator of ANSI C tracers which output CTF data streams";
    homepage = "https://github.com/efficios/barectf";
    license = lib.licenses.mit;
    mainProgram = "barectf";
  };
}
