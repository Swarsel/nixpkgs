{
  lib,
  fetchFromGitHub,
  python3,
}:

let
  pname = "wtfis";
  version = "0.15.0";
  src = fetchFromGitHub {
    owner = "pirxthepilot";
    repo = "wtfis";
    tag = "v${version}";
    hash = "sha256-2e8T2R33xOX4XZ3Lsk95kI9ea245eTWrxA1RPi2PqEI=";
  };
in
python3.pkgs.buildPythonApplication {
  inherit pname version src;

  propagatedBuildInputs = [
    python3.pkgs.hatchling
    python3.pkgs.pydantic
    python3.pkgs.python-dotenv
    python3.pkgs.rich
    python3.pkgs.shodan
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "pydantic"
    "python-dotenv"
    "requests"
    "rich"
    "shodan"
    "types-requests"
  ];

  meta = {
    description = "Passive hostname, domain and IP lookup tool for non-robots";
    homepage = "https://github.com/pirxthepilot/wtfis";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "wtfis";
  };
}
