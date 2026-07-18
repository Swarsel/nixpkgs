{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cython,
  numpy,
  setuptools,
  unittestCheckHook,
}:
buildPythonPackage (finalAttrs: {
  pname = "daqp";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "darnstrom";
    repo = "daqp";
    tag = "v${finalAttrs.version}";
    hash = "sha256-UakuHHsz4LXDfI7+VT5TO+jg90gpgu3lTJL8RGhtODQ=";
  };

  # Don't try to `rmtree` to "Cleanup C-source"
  # TODO: to update on next release, master already has `if daqp_src_exists:`
  postPatch = ''
    substituteInPlace setup.py --replace-fail \
      "if src_path.exists():" \
      "if False:"
  '';

  nativeCheckInputs = [ unittestCheckHook ];

  build-system = [
    cython
    setuptools
  ];

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "daqp" ];
  sourceRoot = "${finalAttrs.src.name}/interfaces/daqp-python";

  unittestFlagsArray = [
    "-s"
    "test"
    "-p"
    "'*.py'"
    "-v"
  ];

  meta = {
    description = "Dual active-set algorithm for convex quadratic programming";
    homepage = "https://github.com/darnstrom/daqp";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ renesat ];
  };
})
