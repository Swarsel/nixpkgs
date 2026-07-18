{
  lib,
  anyio,
  buildPythonPackage,
  distro,
  fetchPypi,
  hatch-fancy-pypi-readme,
  hatchling,
  httpx,
  pydantic,
  sniffio,
  typing-extensions,
}:

buildPythonPackage rec {
  pname = "cloudflare";
  version = "5.5.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-pXFvBqv/FyHQLsuc6DuhXYeVwhbQHCEtTlWzvKb6hiE=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'hatchling==1.26.3' 'hatchling>=1.26.3'
  '';

  # tests require networking
  doCheck = false;

  build-system = [
    hatchling
    hatch-fancy-pypi-readme
  ];

  dependencies = [
    httpx
    pydantic
    typing-extensions
    anyio
    distro
    sniffio
  ];

  pyproject = true;
  pythonImportsCheck = [ "cloudflare" ];

  meta = {
    description = "Official Python library for the Cloudflare API";
    homepage = "https://github.com/cloudflare/cloudflare-python";
    changelog = "https://github.com/cloudflare/cloudflare-python/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      marie
      jemand771
    ];
  };
}
