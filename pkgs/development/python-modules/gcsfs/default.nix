{
  lib,
  fetchFromGitHub,
  # dependencies
  aiohttp,
  buildPythonPackage,
  crcmod,
  decorator,
  fsspec,
  # optional-dependencies
  fusepy,
  google-auth,
  google-auth-oauthlib,
  google-cloud-storage,
  google-cloud-storage-control,
  requests,
  # build-system
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "gcsfs";
  version = "2026.3.0";

  src = fetchFromGitHub {
    owner = "fsspec";
    repo = "gcsfs";
    tag = finalAttrs.version;
    hash = "sha256-RLh3xFW/0qX5labJeUDsRRmQtnTdkvBS+gzJUJ1IP7k=";
  };

  # Tests require a running Docker instance
  doCheck = false;
  __structuredAttrs = true;

  build-system = [
    setuptools
  ];

  dependencies = [
    aiohttp
    decorator
    fsspec
    google-auth
    google-auth-oauthlib
    google-cloud-storage
    google-cloud-storage-control
    requests
  ];

  optional-dependencies = {
    crc = [ crcmod ];
    gcsfuse = [ fusepy ];
  };

  pyproject = true;
  pythonImportsCheck = [ "gcsfs" ];

  meta = {
    description = "Convenient Filesystem interface over GCS";
    homepage = "https://github.com/fsspec/gcsfs";
    changelog = "https://github.com/fsspec/gcsfs/raw/${finalAttrs.src.tag}/docs/source/changelog.rst";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ nbren12 ];
  };
})
