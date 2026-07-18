{
  lib,
  buildPythonPackage,
  fetchPypi,
}:

buildPythonPackage rec {
  pname = "smdebug-rulesconfig";
  version = "1.0.1";

  src = fetchPypi {
    inherit version;
    sha256 = "1mpwjfvpmryqqwlbyf500584jclgm3vnxa740yyfzkvb5vmyc6bs";
    pname = "smdebug_rulesconfig";
  };

  doCheck = false;
  format = "setuptools";
  pythonImportsCheck = [ "smdebug_rulesconfig" ];

  meta = {
    description = "These builtin rules are available in Amazon SageMaker";
    homepage = "https://github.com/awslabs/sagemaker-debugger-rulesconfig";
    license = lib.licenses.asl20;
  };
}
