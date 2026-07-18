{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  poetry-core,
  pytest-cov-stub,
  pytest-xdist,
  pytestCheckHook,
  requests,
}:

buildPythonPackage rec {
  pname = "mficlient";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "uilibs";
    repo = "mficlient";
    tag = "v${version}";
    hash = "sha256-gr9E+3qYD3usK2AAk+autfFQVPL3RDtjG7vvsmZui80=";
  };

  postPatch = ''
    cat >> pyproject.toml << EOF
    [build-system]
    requires = ["poetry-core"]
    build-backend = "poetry.core.masonry.api"
    EOF
  '';

  nativeCheckInputs = [
    pytest-cov-stub
    pytest-xdist
    pytestCheckHook
  ];

  build-system = [ poetry-core ];

  dependencies = [
    requests
  ];

  pyproject = true;
  pythonImportsCheck = [ "mficlient" ];

  meta = {
    description = "Remote control client for Ubiquiti's UVC NVR";
    homepage = "https://github.com/uilibs/mficlient";
    changelog = "https://github.com/uilibs/mficlient/blob/${src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dotlambda ];
    mainProgram = "mfi";
  };
}
