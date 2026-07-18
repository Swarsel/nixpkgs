{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  regex,
  setuptools,
}:

buildPythonPackage rec {
  pname = "somajo";
  version = "2.4.3";

  src = fetchFromGitHub {
    owner = "tsproisl";
    repo = "SoMaJo";
    tag = "v${version}";
    hash = "sha256-fq891LX6PukUEfrXplulhnisuPX/RqLAQ/5ty/Fvm9k=";
  };

  # loops forever
  doCheck = !stdenv.hostPlatform.isDarwin;
  build-system = [ setuptools ];
  dependencies = [ regex ];
  pyproject = true;
  pythonImportsCheck = [ "somajo" ];

  meta = {
    description = "Tokenizer and sentence splitter for German and English web texts";
    homepage = "https://github.com/tsproisl/SoMaJo";
    changelog = "https://github.com/tsproisl/SoMaJo/blob/v${version}/CHANGES.txt";
    license = lib.licenses.gpl3Plus;
    maintainers = [ ];
    mainProgram = "somajo-tokenizer";
  };
}
