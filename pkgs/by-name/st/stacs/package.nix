{
  lib,
  fetchFromGitHub,
  libarchive,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "stacs";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "stacscan";
    repo = "stacs";
    tag = finalAttrs.version;
    hash = "sha256-u0yFzId5RAOnJfTDPRUc8E624zIWyCDe3/WlrJ5iuxA=";
  };

  # remove upstream workaround for darwin
  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail 'if platform.system() == "Darwin":' "if False:"
  '';

  buildInputs = [ libarchive ];

  nativeCheckInputs = with python3.pkgs; [
    pytest-cov-stub
    pytestCheckHook
  ];

  build-system = with python3.pkgs; [
    pybind11
    setuptools
    setuptools-scm
  ];

  dependencies = with python3.pkgs; [
    click
    colorama
    pydantic_1
    yara-python
    zstandard
  ];

  pyproject = true;

  pythonImportsCheck = [
    "stacs"
  ];

  pythonRelaxDeps = [ "yara-python" ];

  meta = {
    description = "Static token and credential scanner";
    homepage = "https://github.com/stacscan/stacs";
    license = with lib.licenses; [ bsd3 ];
    maintainers = with lib.maintainers; [ fab ];
    mainProgram = "stacs";
  };
})
