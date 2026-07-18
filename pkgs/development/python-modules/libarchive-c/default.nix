{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  fetchpatch,
  glibcLocales,
  libarchive,
  mock,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "libarchive-c";
  version = "5.3";

  src = fetchFromGitHub {
    owner = "Changaco";
    repo = "python-libarchive-c";
    tag = finalAttrs.version;
    hash = "sha256-JqXTV1aD3k88OlW+8rT3xsDuW34+1xErG7hkupvL7Uo=";
  };

  patches = [
    # https://github.com/Changaco/python-libarchive-c/pull/141
    (fetchpatch {
      hash = "sha256-C9eD4cGQOIdBYy4ytom49lA/Jaarj7LbSIgjxCk/H84=";
      url = "https://github.com/Changaco/python-libarchive-c/commit/e0e2a47b2403632642ee932dd56acd11e4a79efe.diff";
    })
  ];

  postPatch = ''
    substituteInPlace libarchive/ffi.py --replace-fail \
      "find_library('archive')" "'${libarchive.lib}/lib/libarchive${stdenv.hostPlatform.extensions.sharedLibrary}'"
  '';

  env.LC_ALL = "en_US.UTF-8";

  nativeCheckInputs = [
    glibcLocales
    mock
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  pyproject = true;
  pythonImportsCheck = [ "libarchive" ];

  meta = {
    description = "Python interface to libarchive";
    homepage = "https://github.com/Changaco/python-libarchive-c";
    license = lib.licenses.cc0;
  };
})
