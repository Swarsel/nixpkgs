{
  lib,
  buildPythonPackage,
  fetchPypi,
  twisted,
}:

buildPythonPackage rec {
  pname = "txamqp";
  version = "0.8.2";

  src = fetchPypi {
    inherit version;
    sha256 = "0jd9864k3csc06kipiwzjlk9mq4054s8kzk5q1cfnxj8572s4iv4";
    pname = "txAMQP";
  };

  propagatedBuildInputs = [ twisted ];
  format = "setuptools";

  meta = {
    description = "Library for communicating with AMQP peers and brokers using Twisted";
    homepage = "https://github.com/txamqp/txamqp";
    license = lib.licenses.asl20;
    maintainers = [ ];
  };
}
