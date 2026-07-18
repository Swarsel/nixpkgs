{
  lib,
  fetchFromGitHub,
  python3Packages,
  versionCheckHook,
}:

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "openttd-nml";
  version = "0.9.0";

  src = fetchFromGitHub {
    owner = "OpenTTD";
    repo = "nml";
    tag = finalAttrs.version;
    hash = "sha256-FVGjXh04uHZM9vZNzjdYEk4ClMR9t0kl44JePrUGx84=";
  };

  postPatch = ''
    echo 'version = "${finalAttrs.version}"' > nml/__version__.py

    # Ply's source code is vendored.
    substituteInPlace pyproject.toml \
      --replace-fail '"setuptools", "ply"' '"setuptools"'
  '';

  strictDeps = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  installCheckPhase = ''
    runHook preInstallCheck

    export PYTHON=${python3Packages.python}/bin/python
    export NMLC=$out/bin/nmlc

    make regression

    runHook postInstallCheck
  '';

  __structuredAttrs = true;

  build-system = [
    python3Packages.setuptools
  ];

  dependencies = [
    python3Packages.pillow
  ];

  pyproject = true;

  meta = {
    description = "Compiler for OpenTTD NML files";
    homepage = "https://github.com/OpenTTD/nml";
    changelog = "https://github.com/OpenTTD/nml/releases/tag/${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.magicquark ];
    mainProgram = "nmlc";
  };
})
