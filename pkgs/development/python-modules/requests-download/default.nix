{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit,
  requests,
}:

buildPythonPackage (finalAttrs: {
  pname = "requests-download";
  version = "0.1.2";

  src = fetchFromGitHub {
    owner = "takluyver";
    repo = "requests_download";
    tag = finalAttrs.version;
    hash = "sha256-KLbROCvXNhvnoZHX5aGrXUI38oQuCM88ctIM/02Nmsc=";
  };

  build-system = [ flit ];
  dependencies = [ requests ];
  pyproject = true;

  meta = {
    description = "Download files using requests and save them to a target path";
    homepage = "https://github.com/takluyver/requests_download";
    license = lib.licenses.mit;
  };
})
