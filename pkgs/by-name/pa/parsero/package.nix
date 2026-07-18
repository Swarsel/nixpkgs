{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "parsero";
  version = "0.81";

  src = fetchFromGitHub {
    owner = "behindthefirewalls";
    repo = "parsero";
    rev = "e5b585a19b79426975a825cafa4cc8a353cd267e";
    sha256 = "rqupeJxslL3AfQ+CzBWRb4ZS32VoYd8hlA+eACMKGPY=";
  };

  # Project has no tests
  doCheck = false;
  build-system = with python3Packages; [ setuptools ];

  dependencies = with python3Packages; [
    beautifulsoup4
    urllib3
  ];

  pyproject = true;

  pythonRemoveDeps = [
    "pip" # this dependency is never actually used
  ];

  meta = {
    description = "Robots.txt audit tool";
    homepage = "https://github.com/behindthefirewalls/Parsero";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      emilytrau
      fab
    ];

    mainProgram = "parsero";
  };
}
