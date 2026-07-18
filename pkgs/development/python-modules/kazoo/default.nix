{
  lib,
  buildPythonPackage,
  # optional dependencies
  eventlet,
  fetchPypi,
  gevent,
  pure-sasl,
}:

buildPythonPackage rec {
  pname = "kazoo";
  version = "2.10.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-kFeWrk9MEr1OSukubl0BhDnmtWyM+7JIJTYuebIw2rE=";
  };

  # tests take a long time to run and leave threads hanging
  doCheck = false;
  format = "setuptools";

  optional-dependencies = {
    eventlet = [ eventlet ];
    gevent = [ gevent ];
    sasl = [ pure-sasl ];
  };

  pythonImportsCheck = [
    "kazoo"
    "kazoo.client"
  ];

  meta = {
    description = "Higher Level Zookeeper Client";
    homepage = "https://kazoo.readthedocs.org";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
