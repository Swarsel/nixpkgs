{
  lib,
  buildPythonPackage,
  fetchPypi,
  msgpack,
  python-memcached,
  redis,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "cachy";
  version = "0.3.0";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-GGWB9M60Kgu+BAxAfac8FAkjebHkwOMn/bcq5KmyabE=";
  };

  # The Pypi tarball doesn't include tests, and the GitHub source isn't
  # buildable until we bootstrap poetry, see
  # https://github.com/NixOS/nixpkgs/pull/53599#discussion_r245855665
  doCheck = false;
  __structuredAttrs = true;
  build-system = [ setuptools ];

  dependencies = [
    redis
    python-memcached
    msgpack
  ];

  pyproject = true;
  pythonImportsCheck = [ "cachy" ];

  meta = {
    description = "Cachy provides a simple yet effective caching library";
    homepage = "https://github.com/sdispater/cachy";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ jakewaksbaum ];
  };
})
