{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  hopcroftkarp,
  hypothesis,
  multiset,
  pytestCheckHook,
  setuptools-scm,
}:

buildPythonPackage rec {
  pname = "matchpy";
  version = "0.5.5"; # Don't upgrade to 4.3.1, this tag is very old

  src = fetchFromGitHub {
    owner = "HPAC";
    repo = "matchpy";
    rev = version;
    hash = "sha256-n5rXIjqVQZzEbfIZVQiGLh2PR1DHAJ9gumcrbvwnasA=";
  };

  patches = [
    # https://github.com/HPAC/matchpy/pull/77
    (fetchpatch {
      hash = "sha256-xXADCSIhq1ARny2twzrhR1J8LkMFWFl6tmGxrM8RvkU=";
      name = "fix-versioneer-py312.patch";
      url = "https://github.com/HPAC/matchpy/commit/965d7c39689b9f2473a78ed06b83f2be701e234d.patch";
    })
  ];

  postPatch = ''
    sed -i '/pytest-runner/d' setup.cfg

    substituteInPlace setup.cfg \
      --replace "multiset>=2.0,<3.0" "multiset"
  '';

  nativeBuildInputs = [ setuptools-scm ];

  propagatedBuildInputs = [
    hopcroftkarp
    multiset
  ];

  nativeCheckInputs = [
    pytestCheckHook
    hypothesis
  ];

  format = "setuptools";
  pythonImportsCheck = [ "matchpy" ];

  meta = {
    description = "Library for pattern matching on symbolic expressions";
    homepage = "https://github.com/HPAC/matchpy";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
}
