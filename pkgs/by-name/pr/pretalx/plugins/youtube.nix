{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pretalx-youtube";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "pretalx";
    repo = "pretalx-youtube";
    rev = "v${version}";
    hash = "sha256-mudTB2qyCUkLwQsbbPiQuBeEscJQROdPWdjWmfOY7Vw=";
  };

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "pretalx_youtube" ];

  meta = {
    description = "Static youtube for pretalx, e.g. information, venue listings, a Code of Conduct, etc";
    homepage = "https://github.com/pretalx/pretalx-youtube";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ wegank ];
  };
}
