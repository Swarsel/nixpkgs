{
  lib,
  buildPythonPackage,
  fetchpatch2,
  fetchzip,
  mercurial,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "python-hglib";
  version = "2.6.2";

  src = fetchzip {
    url = "https://repo.mercurial-scm.org/python-hglib/archive/${version}.tar.gz";
    hash = "sha256-UXersegqJ9VAxy4Kvpb2IiOJfQbWryeeaGvwiR4ncW8=";
  };

  patches = [
    (fetchpatch2 {
      excludes = [ "heptapod-ci.yml" ];
      hash = "sha256-4gicVCAH94itxHY0l8ek0L/RVhUrw2lMbbnENbWrV6U=";
      name = "remove-nose.patch";
      url = "https://repo.mercurial-scm.org/python-hglib/raw-rev/8341f2494b3fc1c0d9ee55fa4487c0ac82f64d2a";
    })
    (fetchpatch2 {
      hash = "sha256-T/yKJ8cMMOBVk24SXwyPOoD321S1fZEIunaPJAxI0KI=";
      name = "fix-tests.patch";
      url = "https://repo.mercurial-scm.org/python-hglib/raw-rev/a2afbf236ca86287e72f54e1248413625d1bc405";
    })
  ];

  nativeCheckInputs = [
    mercurial
    pytestCheckHook
  ];

  preCheck = ''
    export HGTMP=$(mktemp -d)
    export HGUSER=test
  '';

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "hglib" ];

  meta = {
    description = "Library with a fast, convenient interface to Mercurial. It uses Mercurial’s command server for communication with hg";
    homepage = "https://www.mercurial-scm.org/wiki/PythonHglibs";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
