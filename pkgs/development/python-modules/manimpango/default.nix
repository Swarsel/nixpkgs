{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  pango,
  pkg-config,
  pytest-cov-stub,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "manimpango";
  version = "0.6.1";

  src = fetchFromGitHub {
    owner = "ManimCommunity";
    repo = "manimpango";
    tag = "v${version}";
    hash = "sha256-8eQmhVsW440/zxOwjngnPTGT7iFbdSvBV7tnI332piE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail "Cython>=3.0.2,<3.1" Cython
  '';

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ pango ];

  nativeCheckInputs = [
    pytest-cov-stub
    pytestCheckHook
  ];

  preCheck = ''
    rm -r manimpango
  '';

  build-system = [
    setuptools
    cython
  ];

  pyproject = true;
  pythonImportsCheck = [ "manimpango" ];

  meta = {
    description = "Binding for Pango";
    homepage = "https://github.com/ManimCommunity/ManimPango";
    changelog = "https://github.com/ManimCommunity/ManimPango/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ emilytrau ];
  };
}
