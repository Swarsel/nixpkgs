{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  pytestCheckHook,
  setuptools,
  tinycss2,
  webencodings,
}:

buildPythonPackage (finalAttrs: {
  pname = "bleach";
  version = "6.3.0";

  src = fetchFromGitHub {
    owner = "mozilla";
    repo = "bleach";
    tag = "v${finalAttrs.version}";
    hash = "sha256-a85gLy0Ix4cWvXY0s3m+ZD+ga7en6bYu1iAA22OaSwk=";
  };

  nativeCheckInputs = [ pytestCheckHook ];
  build-system = [ setuptools ];

  dependencies = [
    webencodings
  ];

  disabledTests = [
    # Disable network tests
    "protocols"
  ];

  optional-dependencies = {
    css = [ tinycss2 ];
  };

  pyproject = true;
  pythonImportsCheck = [ "bleach" ];

  pythonRelaxDeps = [
    # Upstream views pins as known-good versions: https://github.com/mozilla/bleach/pull/741
    "tinycss2"
  ];

  meta = {
    description = "Easy, HTML5, whitelisting HTML sanitizer";

    longDescription = ''
      Bleach is an HTML sanitizing library that escapes or strips markup and
      attributes based on a white list. Bleach can also linkify text safely,
      applying filters that Django's urlize filter cannot, and optionally
      setting rel attributes, even on links already in the text.

      Bleach is intended for sanitizing text from untrusted sources. If you
      find yourself jumping through hoops to allow your site administrators
      to do lots of things, you're probably outside the use cases. Either
      trust those users, or don't.
    '';

    homepage = "https://github.com/mozilla/bleach";
    changelog = "https://github.com/mozilla/bleach/blob/${finalAttrs.src.tag}/CHANGES";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ prikhi ];
    downloadPage = "https://github.com/mozilla/bleach/releases";
  };
})
