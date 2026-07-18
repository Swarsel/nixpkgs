{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  mac-alias,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "ds-store";
  version = "1.3.2";

  src = fetchFromGitHub {
    owner = "al45tair";
    repo = "ds_store";
    tag = "v${version}";
    hash = "sha256-UqBZ6w9y+eOQ+OdhXJReT4GwaxEbrGFvmUQMrNyBdjU=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "setuptools==80.9.0" "setuptools"
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  dependencies = [ mac-alias ];
  pyproject = true;
  pythonImportsCheck = [ "ds_store" ];

  meta = {
    description = "Manipulate Finder .DS_Store files from Python";
    homepage = "https://github.com/al45tair/ds_store";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ prusnak ];
    mainProgram = "ds_store";
  };
}
