{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "itchiodl";
  version = "2.3.0";

  src = fetchFromGitHub {
    owner = "Emersont1";
    repo = "itchio";
    rev = "v${finalAttrs.version}";
    hash = "sha256-XuNkqTAT9LlSwruchGQbombAKHZvKhpnqLfvJdDcrj0=";
  };

  nativeBuildInputs = with python3Packages; [
    poetry-core
  ];

  propagatedBuildInputs = with python3Packages; [
    beautifulsoup4
    clint
    requests
  ];

  pyproject = true;

  meta = {
    description = "itch.io download tool";
    homepage = "https://github.com/Emersont1/itchio";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ fgaz ];
  };
})
