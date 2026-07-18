{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libffi,
  pkg-config,
  pycparser,
  pytestCheckHook,
  setuptools,
}:

buildPythonPackage rec {
  pname = "cffi";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "python-cffi";
    repo = "cffi";
    tag = "v${version}";
    hash = "sha256-7Mzz3KmmmE2xQru1GA4aY0DZqn6vxykWiExQvnA1bjM=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libffi ];
  doCheck = !(stdenv.hostPlatform.isMusl || stdenv.hostPlatform.useLLVM or false);
  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];
  # Some dependent packages expect to have pycparser available when using cffi.
  dependencies = [ pycparser ];

  disabledTests = [
    # parse errror
    "test_dont_remove_comment_in_line_directives"
    "test_multiple_line_directives"
    "test_commented_line_directive"
    # exception mismatch
    "test_unknown_name"
  ];

  pyproject = true;

  meta = {
    description = "Foreign Function Interface for Python calling C code";
    homepage = "https://cffi.readthedocs.org/";
    changelog = "https://github.com/python-cffi/cffi/releases/tag/v${version}";
    license = lib.licenses.mit0;
    downloadPage = "https://github.com/python-cffi/cffi";
    teams = [ lib.teams.python ];
  };
}
