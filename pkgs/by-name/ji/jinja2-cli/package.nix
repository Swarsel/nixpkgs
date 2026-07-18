{
  lib,
  fetchFromGitHub,
  python3,
  extras ? [
    "hjson"
    "json5"
    "toml"
    "xml"
    "yaml"
  ],
}:

python3.pkgs.buildPythonApplication rec {
  pname = "jinja2-cli";
  version = "0.8.2";

  src = fetchFromGitHub {
    owner = "mattrobenolt";
    repo = "jinja2-cli";
    rev = version;
    hash = "sha256-67gYt0nZX+VTVaoSxVXGzbRiXD7EMsVBFWC8wHo+Vw0=";
  };

  nativeBuildInputs = [
    python3.pkgs.setuptools
    python3.pkgs.wheel
  ];

  propagatedBuildInputs =
    with python3.pkgs;
    [
      jinja2
    ]
    ++ lib.flatten (lib.attrVals extras optional-dependencies);

  nativeCheckInputs = [
    python3.pkgs.pytestCheckHook
  ];

  optional-dependencies = with python3.pkgs; {
    hjson = [ hjson ];
    json5 = [ json5 ];
    toml = [ toml ];
    xml = [ xmltodict ];
    yaml = [ pyyaml ];
  };

  pyproject = true;
  pythonImportsCheck = [ "jinja2cli" ];

  meta = {
    description = "CLI for Jinja2";
    homepage = "https://github.com/mattrobenolt/jinja2-cli";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    mainProgram = "jinja2";
  };
}
