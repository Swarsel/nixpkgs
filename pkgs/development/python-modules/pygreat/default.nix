{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pyusb,
  setuptools,
}:

buildPythonPackage rec {
  pname = "pygreat";
  version = "2026.0.0";

  src = fetchFromGitHub {
    owner = "greatscottgadgets";
    repo = "libgreat";
    tag = "v${version}";
    hash = "sha256-m+s2TAJK7UhKWbuSd5ec1O40WeMXxJyTD9yqPOr0LEM=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools-git-versioning<2"' "" \
      --replace-fail 'dynamic = ["version"]' 'version = "${version}"'
  '';

  # Module has no tests
  doCheck = false;
  build-system = [ setuptools ];
  dependencies = [ pyusb ];
  pyproject = true;
  pythonImportsCheck = [ "pygreat" ];
  sourceRoot = "${src.name}/host";

  meta = {
    description = "Python library for talking with libGreat devices";
    homepage = "https://github.com/greatscottgadgets/libgreat/";
    changelog = "https://github.com/greatscottgadgets/libgreat/releases/tag/${src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ carlossless ];
  };
}
