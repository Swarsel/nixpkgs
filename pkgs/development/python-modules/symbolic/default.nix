{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cargo,
  cffi,
  milksnake,
  nix-update-script,
  pytestCheckHook,
  rustPlatform,
  rustc,
  setuptools-rust,
}:

buildPythonPackage (finalAttrs: {
  pname = "symbolic";
  version = "13.9.0";

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "symbolic";
    tag = finalAttrs.version;
    hash = "sha256-o7LqQb+tWpAl+W5sHI51tfd2FEZOpPPgChIpkXjM1D8=";
    # the `py` directory is not included in the tarball, so we fetch the source via git instead
    forceFetchGit = true;
  };

  nativeBuildInputs = [
    setuptools-rust
    rustPlatform.cargoSetupHook
    rustc
    cargo
    milksnake
  ];

  preBuild = ''
    cd py
  '';

  nativeCheckInputs = [ pytestCheckHook ];

  preCheck = ''
    cd ..
  '';

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-q2+eJufBBzPJEgVqmUagXSU9fQPHQv4jfyCVgHJLBsk=";
  };

  dependencies = [ cffi ];
  enabledTestPaths = [ "py" ];
  pyproject = true;
  pythonImportsCheck = [ "symbolic" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Python library for dealing with symbol files and more";
    homepage = "https://github.com/getsentry/symbolic";
    changelog = "https://github.com/getsentry/symbolic/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ defelo ];
  };
})
