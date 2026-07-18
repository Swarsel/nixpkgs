{
  lib,
  fetchFromGitHub,
  aiooss2,
  buildPythonPackage,
  fsspec,
  oss2,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "ossfs";
  version = "2025.5.0";

  src = fetchFromGitHub {
    owner = "fsspec";
    repo = "ossfs";
    tag = version;
    hash = "sha256-2i7zxLCi4wNCwzWNUbC6lvvdRkK+ksUWds+H6QG6bW4=";
  };

  nativeBuildInputs = [
    setuptools-scm
  ];

  propagatedBuildInputs = [
    aiooss2
    fsspec
    oss2
  ];

  # Most tests require network access
  doCheck = false;
  pyproject = true;
  pythonImportsCheck = [ "ossfs" ];

  pythonRelaxDeps = [
    "aiooss2"
    "fsspec"
    "oss2"
  ];

  meta = {
    description = "Filesystem for Alibaba Cloud (Aliyun) Object Storage System (OSS)";
    homepage = "https://github.com/fsspec/ossfs";
    changelog = "https://github.com/fsspec/ossfs/releases/tag/${src.tag}";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ fab ];
  };
}
