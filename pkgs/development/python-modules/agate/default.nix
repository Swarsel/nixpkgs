{
  lib,
  stdenv,
  fetchFromGitHub,
  babel,
  buildPythonPackage,
  cssselect,
  glibcLocales,
  isodate,
  leather,
  lxml,
  parsedatetime,
  pyicu,
  pytestCheckHook,
  python-slugify,
  pytimeparse,
  setuptools,
}:

buildPythonPackage (finalAttrs: {
  pname = "agate";
  version = "1.14.1";

  src = fetchFromGitHub {
    owner = "wireservice";
    repo = "agate";
    tag = finalAttrs.version;
    hash = "sha256-REo26vSWFzWsvJzmqlc5A5xEYA2TebQFW6jFRIbH53I=";
  };

  nativeCheckInputs = [
    cssselect
    glibcLocales
    lxml
    pyicu
    pytestCheckHook
  ];

  build-system = [ setuptools ];

  dependencies = [
    babel
    isodate
    leather
    parsedatetime
    python-slugify
    pytimeparse
  ];

  disabledTests = lib.optionals stdenv.hostPlatform.isDarwin [
    # Output is slightly different on macOS
    "test_cast_format_locale"
  ];

  pyproject = true;
  pythonImportsCheck = [ "agate" ];

  meta = {
    description = "Python data analysis library that is optimized for humans instead of machines";
    homepage = "https://github.com/wireservice/agate";
    changelog = "https://github.com/wireservice/agate/blob/${finalAttrs.src.tag}/CHANGELOG.rst";
    license = lib.licenses.mit;
    maintainers = [ ];
  };
})
