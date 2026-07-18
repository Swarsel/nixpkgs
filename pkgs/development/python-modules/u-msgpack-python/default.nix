{
  lib,
  buildPythonPackage,
  fetchPypi,
  glibcLocales,
  unittestCheckHook,
}:

buildPythonPackage rec {
  pname = "u-msgpack-python";
  version = "2.8.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-uAGoPW7XXm30HkRRi08qnCIdwtpLzVOA46D+2lILxho=";
  };

  buildInputs = [ glibcLocales ];
  env.LC_ALL = "en_US.UTF-8";
  nativeCheckInputs = [ unittestCheckHook ];
  format = "setuptools";

  meta = {
    description = "Portable, lightweight MessagePack serializer and deserializer written in pure Python";
    homepage = "https://github.com/vsergeev/u-msgpack-python";
    changelog = "https://github.com/vsergeev/u-msgpack-python/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.mit;
  };
}
