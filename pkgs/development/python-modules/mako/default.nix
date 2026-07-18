{
  lib,
  fetchFromGitHub,
  # optional-dependencies
  babel,
  buildPythonPackage,
  # tests
  chameleon,
  isPyPy,
  lingua,
  # propagates
  markupsafe,
  mock,
  pytestCheckHook,
  # build-system
  setuptools_80,
}:

buildPythonPackage (finalAttrs: {
  pname = "mako";
  version = "1.3.12";

  src = fetchFromGitHub {
    owner = "sqlalchemy";
    repo = "mako";
    tag = "rel_${lib.replaceString "." "_" finalAttrs.version}";
    hash = "sha256-YIMmP8CIGUlgnB8/96lR9yDvEZTES766dSN0vT0JfbM=";
  };

  nativeCheckInputs = [
    chameleon
    mock
    pytestCheckHook
  ]
  ++ lib.concatAttrValues finalAttrs.passthru.optional-dependencies;

  build-system = [ setuptools_80 ];
  dependencies = [ markupsafe ];

  disabledTests = lib.optionals isPyPy [
    # https://github.com/sqlalchemy/mako/issues/315
    "test_alternating_file_names"
    # https://github.com/sqlalchemy/mako/issues/238
    "test_file_success"
    "test_stdin_success"
    # fails on pypy2.7
    "test_bytestring_passthru"
  ];

  optional-dependencies = {
    babel = [ babel ];
    lingua = [ lingua ];
  };

  pyproject = true;

  meta = {
    description = "Super-fast templating language";
    homepage = "https://www.makotemplates.org/";
    changelog = "https://github.com/sqlalchemy/mako/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "mako-render";
  };
})
