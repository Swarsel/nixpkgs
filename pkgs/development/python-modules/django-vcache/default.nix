{
  lib,
  fetchFromGitLab,
  buildPythonPackage,
  django,
  hatchling,
  ormsgpack,
  pythonOlder,
  pyzstd,
  rustPlatform,
}:

buildPythonPackage (finalAttrs: {
  pname = "django-vcache";
  version = "2.3.0";

  src = fetchFromGitLab {
    owner = "glitchtip";
    repo = "django-vcache";
    tag = "v${finalAttrs.version}";
    hash = "sha256-/LyNJlz3Tx6tgQAwY4vIIsDlL2nCvKM6bna2bXyP5So=";
  };

  nativeBuildInputs = [
    rustPlatform.cargoSetupHook
    rustPlatform.maturinBuildHook
  ];

  # requires valkey sentinel cluster
  doCheck = false;
  build-system = [ hatchling ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) src;
    hash = "sha256-a9+3k6YTotmj+LBO6OyVd2NUh3hpLwpKXJsX7pBxXNE=";
  };

  dependencies = [
    django
    ormsgpack
  ]
  ++ lib.optional (pythonOlder "3.14") pyzstd;

  pyproject = true;
  pythonImportsCheck = [ "django_vcache" ];

  meta = {
    description = "Specialized, lightweight Django cache backend for Valkey";
    homepage = "https://gitlab.com/glitchtip/django-vcache/";

    changelog = "https://gitlab.com/glitchtip/django-vcache/-/blob/main/CHANGELOG.md#${
      lib.replaceString "." "" finalAttrs.version
    }";

    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      defelo
      felbinger
    ];
  };
})
