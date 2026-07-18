{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  makeWrapper,
  pytestCheckHook,
  python,
  setuptools,
}:

buildPythonPackage rec {
  pname = "hjson";
  version = "3.0.2";

  src = fetchFromGitHub {
    owner = "hjson";
    repo = "hjson-py";
    tag = "v${version}";
    hash = "sha256-VrCLHfXShF45IEhGVQpryBzjxreQEunyghazDNKRh8k=";
  };

  nativeBuildInputs = [ makeWrapper ];
  nativeCheckInputs = [ pytestCheckHook ];

  postInstall = ''
    rm $out/bin/hjson.cmd
    wrapProgram $out/bin/hjson  \
      --set PYTHONPATH "$PYTHONPATH" \
      --prefix PATH : ${lib.makeBinPath [ python ]}
  '';

  build-system = [ setuptools ];

  disabledTestPaths = [
    # AttributeError:  b'/build/source/hjson/tool.py:14: Deprecati[151 chars]ools' != b''
    "hjson/tests/test_tool.py"
  ];

  pyproject = true;
  pythonImportsCheck = [ "hjson" ];

  meta = {
    description = "User interface for JSON";
    homepage = "https://github.com/hjson/hjson-py";
    changelog = "https://github.com/hjson/hjson-py/releases/tag/v${version}";
    license = lib.licenses.mit;
    mainProgram = "hjson";
  };
}
