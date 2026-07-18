{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pip,
  psutil,
  requests,
  setuptools,
  toml,
  tqdm,
}:
buildPythonPackage rec {
  pname = "language-tool-python";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "jxmorris12";
    repo = "language_tool_python";
    tag = version;
    hash = "sha256-EX6O9bYJgrgvKkFDjq3A144iFkcwNPIvTTEIC9D9J6M=";
  };

  build-system = [ setuptools ];

  dependencies = [
    requests
    tqdm
    psutil
    toml
    pip
  ];

  pyproject = true;

  meta = {
    description = "Free python grammar checker";
    homepage = "https://github.com/jxmorris12/language_tool_python";
    changelog = "https://github.com/jxmorris12/language_tool_python/releases/tag/${src.tag}";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ justdeeevin ];
    platforms = lib.platforms.all;
  };
}
