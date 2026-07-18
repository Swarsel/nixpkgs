{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  flit-core,
  nodejs,
  pytestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "pscript";
  version = "0.8.0";

  src = fetchFromGitHub {
    owner = "flexxui";
    repo = "pscript";
    tag = "v${finalAttrs.version}";
    hash = "sha256-pqjig3dFJ4zfpor6TT6fiBMS7lAtJE/bAYbzl46W/YY=";
  };

  postPatch = ''
    # https://github.com/flexxui/pscript/pull/77
    substituteInPlace pscript/commonast.py \
      --replace-fail "ast.Ellipsis" "ast.Constant"
  '';

  nativeCheckInputs = [
    pytestCheckHook
    nodejs
  ];

  preCheck = ''
    # do not execute legacy tests
    rm -rf pscript_legacy
  '';

  build-system = [ flit-core ];

  disabledTests = [
    # https://github.com/flexxui/pscript/issues/69
    "test_async_and_await"
  ];

  pyproject = true;
  pythonImportsCheck = [ "pscript" ];

  meta = {
    description = "Python to JavaScript compiler";
    homepage = "https://pscript.readthedocs.io";
    changelog = "https://github.com/flexxui/pscript/blob/${finalAttrs.src.tag}/docs/releasenotes.rst";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ matthiasbeyer ];
  };
})
