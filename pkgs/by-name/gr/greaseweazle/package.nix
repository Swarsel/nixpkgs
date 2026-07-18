{
  lib,
  fetchFromGitHub,
  python3,
}:

python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "greaseweazle";
  version = "1.23";

  src = fetchFromGitHub {
    owner = "keirf";
    repo = "greaseweazle";
    rev = "v${finalAttrs.version}";
    hash = "sha256-ey9srzGnyaZ5TmeSXo7AQwh93Iufim41mgJnJXHSIyc=";
  };

  build-system = with python3.pkgs; [
    setuptools
    setuptools-scm
    wheel
  ];

  dependencies = with python3.pkgs; [
    crcmod
    bitarray
    pyserial
    requests
  ];

  pyproject = true;

  pythonImportsCheck = [
    "greaseweazle"
  ];

  meta = {
    description = "Tools for accessing a floppy drive at the raw flux level";
    homepage = "https://github.com/keirf/greaseweazle";
    license = lib.licenses.unlicense;
    maintainers = with lib.maintainers; [ matthewcroughan ];
    mainProgram = "greaseweazle";
  };
})
