{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  setuptools,
  tomli,
  wheel,
}:

buildPythonPackage rec {
  pname = "setuptools-changelog-shortener";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "fschulze";
    repo = "setuptools-changelog-shortener";
    tag = version;
    hash = "sha256-K8oVcX40K5j2CwQnulK55HykkEXAmOiUg4mZPg5T+YI=";
  };

  nativeBuildInputs = [
    setuptools
    tomli
    wheel
  ];

  # upstream has no tests
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "setuptools_changelog_shortener" ];

  meta = {
    description = "Setuptools-changelog-shortener: add only newest changelog entries to long_description";
    homepage = "https://github.com/fschulze/setuptools-changelog-shortener";
    changelog = "https://github.com/fschulze/setuptools-changelog-shortener/blob/${src.rev}/README.rst#changelog";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ natsukium ];
  };
}
