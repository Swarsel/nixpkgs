{
  lib,
  fetchPypi,
  fetchpatch,
  nixosTests,
  python3,
}:

with python3.pkgs;

buildPythonPackage (finalAttrs: {
  pname = "postorius";
  version = "1.3.13";

  src = fetchPypi {
    inherit (finalAttrs) pname version;
    hash = "sha256-YC3vXEhSkA1J6K2VGWojNOE8MeSdnAhZMkh558UTGiI=";
  };

  patches = [
    (fetchpatch {
      excludes = [ "src/postorius/doc/news.rst" ];
      hash = "sha256-M8C7mO/KoVhl1YtZ5x3wqL+aBkepJ/7NoIRUmd0JpiM=";
      name = "security-fix.patch";
      url = "https://gitlab.com/mailman/postorius/-/commit/c4706abd05ba6bcf472fc674b160d3a9d6a4868b.patch";
    })

    (fetchpatch {
      excludes = [
        ".gitlab-ci.yml"
        "src/postorius/doc/news.rst"
      ];

      hash = "sha256-4yk7hLF6cRfS7Kelr49LPeVfrqvNoX1jxTy8sdGrMAk=";
      name = "django-5.2.patch";
      url = "https://gitlab.com/mailman/postorius/-/commit/0468ab0329df85b89e6b5d9f7b4d1805f47450c9.patch";
    })
  ];

  # Tries to connect to database.
  doCheck = false;

  nativeCheckInputs = [
    beautifulsoup4
    vcrpy
    mock
  ];

  build-system = [ pdm-backend ];

  dependencies = [
    django-mailman3
    readme-renderer
  ]
  ++ readme-renderer.optional-dependencies.md;

  format = "pyproject";
  passthru.tests = { inherit (nixosTests) mailman; };

  meta = {
    description = "Web-based user interface for managing GNU Mailman";
    homepage = "https://docs.mailman3.org/projects/postorius";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ qyliss ];
  };
})
