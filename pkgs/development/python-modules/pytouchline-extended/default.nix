{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  faust-cchardet,
  httpx,
  pytest-asyncio,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "pytouchline-extended";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "brondum";
    repo = "pytouchline";
    tag = finalAttrs.version;
    hash = "sha256-sIrHvC+IkJWgNksgS5lB4IFP37xggVypMLmGjjLlaVQ=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail '$GITHUB_REF_NAME' '${finalAttrs.version}'
  '';

  nativeCheckInputs = [
    pytest-asyncio
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    faust-cchardet
    httpx
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytouchline_extended" ];

  meta = {
    description = "Roth Touchline interface library";
    homepage = "https://github.com/brondum/pytouchline";
    changelog = "https://github.com/brondum/pytouchline/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
  };
})
