{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  py-cid,
  pytest-cov-stub,
  pytestCheckHook,
}:

buildPythonPackage rec {
  pname = "pytest-cid";
  version = "1.1.2";

  src = fetchFromGitHub {
    owner = "ntninja";
    repo = "pytest-cid";
    tag = "v${version}";
    hash = "sha256-dcL/i5+scmdXh7lfE8+32w9PdHWf+mkunJL1vpJ5+Co=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace "pytest >= 5.0, < 7.0" "pytest >= 5.0"
  '';

  nativeBuildInputs = [ flit-core ];
  propagatedBuildInputs = [ py-cid ];

  nativeCheckInputs = [
    pytestCheckHook
    pytest-cov-stub
  ];

  pyproject = true;
  pythonImportsCheck = [ "pytest_cid" ];

  meta = {
    description = "Simple wrapper around py-cid for easily writing tests involving CIDs in datastructures";
    homepage = "https://github.com/ntninja/pytest-cid";
    license = lib.licenses.mpl20;
    maintainers = with lib.maintainers; [ Luflosi ];
  };
}
