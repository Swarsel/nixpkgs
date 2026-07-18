{
  lib,
  buildPythonPackage,
  fetchPypi,
  numpy,
  uv-build,
}:

buildPythonPackage rec {
  pname = "numpy-typing-compat";
  version = "20251206.2.4";

  src = fetchPypi {
    inherit version;
    hash = "sha256-WYgtI6r/BUolNtqAVkASzc4zSHZXvk15xZJbuHBfyrw=";
    pname = "numpy_typing_compat";
  };

  postPatch = ''
    substituteInPlace pyproject.toml --replace-fail "uv_build>=0.9,<0.10" "uv_build>=0.9,<=0.10"
  '';

  build-system = [
    uv-build
  ];

  dependencies = [
    numpy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "numpy_typing_compat"
  ];

  meta = {
    description = "Static typing compatibility layer for older versions of NumPy";
    homepage = "https://pypi.org/project/numpy-typing-compat/";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ tm-drtina ];
  };
}
