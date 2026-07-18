{
  lib,
  afew,
  fetchPypi,
  pkgs,
  python3Packages,
  testers,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "afew";
  version = "3.0.1";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    sha256 = "0wpfqbqjlfb9z0hafvdhkm7qw56cr9kfy6n8vb0q42dwlghpz1ff";
  };

  outputs = [
    "out"
    "doc"
    "man"
  ];

  nativeBuildInputs = with python3Packages; [
    sphinxHook
    setuptools_80
    setuptools-scm
  ];

  propagatedBuildInputs = with python3Packages; [
    chardet
    dkimpy
    notmuch
    setuptools
  ];

  nativeCheckInputs = [
    pkgs.notmuch
  ]
  ++ (with python3Packages; [
    freezegun
    pytestCheckHook
  ]);

  makeWrapperArgs = [
    ''--prefix PATH ':' "${pkgs.notmuch}/bin"''
  ];

  pyproject = true;

  sphinxBuilders = [
    "html"
    "man"
  ];

  passthru.tests = {
    version = testers.testVersion {
      package = afew;
    };
  };

  meta = {
    description = "Initial tagging script for notmuch mail";
    homepage = "https://github.com/afewmail/afew";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ flokli ];
    mainProgram = "afew";
  };
})
