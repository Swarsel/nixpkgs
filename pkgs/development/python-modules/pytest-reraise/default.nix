{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-reraise";
  version = "2.1.2";

  src = fetchFromGitHub {
    owner = "bjoluc";
    repo = "pytest-reraise";
    tag = "v${version}";
    hash = "sha256-mgNKoZ+2sinArTZhSwhLxzBTb4QfiT1LWBs7w5MHXWA=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'poetry>=0.12' 'poetry-core>=1.0.0' \
      --replace-fail 'poetry.masonry' 'poetry.core.masonry'
  '';

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ poetry-core ];
  dependencies = [ pytest ];
  pyproject = true;
  pythonImportsCheck = [ "pytest_reraise" ];

  meta = {
    description = "Make multi-threaded pytest test cases fail when they should";

    longDescription = ''
      Make multi-threaded pytest test cases fail when they should
    '';

    homepage = "https://github.com/bjoluc/pytest-reraise";
    changelog = "https://github.com/bjoluc/pytest-reraise/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ cpcloud ];
  };
}
