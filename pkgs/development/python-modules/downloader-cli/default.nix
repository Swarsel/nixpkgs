{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  urllib3,
}:

buildPythonPackage rec {
  pname = "downloader-cli";
  version = "0.3.4";

  src = fetchFromGitHub {
    owner = "deepjyoti30";
    repo = "downloader-cli";
    tag = version;
    hash = "sha256-E2K3n9qCQofm4gXu1l7/0iMoJsniuzhsBUplr4aZ39s=";
  };

  propagatedBuildInputs = [ urllib3 ];
  # Disable checks due to networking (Errno 101)
  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "downloader_cli" ];

  meta = {
    description = "Downloader with an awesome customizable progressbar";
    homepage = "https://github.com/deepjyoti30/downloader-cli";
    changelog = "https://github.com/deepjyoti30/downloader-cli/releases/tag/${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ j0hax ];
    mainProgram = "dw";
  };
}
