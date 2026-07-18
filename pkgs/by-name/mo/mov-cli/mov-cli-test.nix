{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  devgoldyutils,
  pytubefix,
  requests,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "mov-cli-test";
  version = "1.1.7";

  src = fetchFromGitHub {
    owner = "mov-cli";
    repo = "mov-cli-test";
    tag = version;
    hash = "sha256-INdPAJxPxfo5bKg4Xn1r7bildxznXrTJxmDI21wylnI=";
  };

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    pytubefix
    requests
    devgoldyutils
  ];

  doCheck = false;
  pyproject = true;

  meta = {
    description = "Mov-cli plugin that let's you test mov-cli's capabilities by watching free films and animations in the creative commons";
    homepage = "https://github.com/mov-cli/mov-cli-test";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ youhaveme9 ];
  };
}
