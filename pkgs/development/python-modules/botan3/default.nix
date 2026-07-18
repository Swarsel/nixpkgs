{
  lib,
  stdenv,
  # dependencies
  botan3,
  buildPythonPackage,
  # build dependencies
  setuptools,
  setuptools-scm,
}:

buildPythonPackage rec {
  inherit (botan3) src version;
  pname = "botan3";

  postPatch = ''
    # remove again, when https://github.com/randombit/botan/pull/5040 got
    # merged
    cp ${./pyproject.toml} pyproject.toml
  ''
  + (
    if stdenv.hostPlatform.isDarwin then
      ''
        botanLibPath=$(find ${lib.getLib botan3}/lib -name 'libbotan-3.dylib' -print -quit)
        substituteInPlace botan3.py --replace-fail 'libbotan-3.dylib' "$botanLibPath"
      ''
    else if stdenv.hostPlatform.isMinGW then
      ''
        botanLibPath=$(find ${lib.getLib botan3}/lib -name 'libbotan-3.dll' -print -quit)
        substituteInPlace botan3.py --replace-fail 'libbotan-3.dll' "$botanLibPath"
      ''
    # Linux/other Unix-like system
    else
      ''
        botanLibPath=$(find ${lib.getLib botan3}/lib -name 'libbotan-3.so' -print -quit)
        substituteInPlace botan3.py --replace-fail 'libbotan-3.so' "$botanLibPath"
      ''
  );

  # not necessary for build, but makes it easier to discover for
  # SBOM tooling
  nativeBuildInputs = [
    setuptools
    setuptools-scm
  ];

  # not necessary for build, but makes it easier to discover for
  # SBOM tooling
  buildInputs = [ botan3 ];

  build-system = [
    setuptools
    setuptools-scm
  ];

  pyproject = true;
  pythonImportsCheck = [ "botan3" ];
  sourceRoot = "source/src/python";

  meta = {
    description = "Python Bindings for botan3 cryptography library";
    homepage = "https://github.com/randombit/botan";
    changelog = "https://github.com/randombit/botan/blob/${version}/news.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ thillux ];
  };
}
