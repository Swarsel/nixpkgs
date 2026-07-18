{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libiconv,
  numpy,
  rustPlatform,
  unittestCheckHook,
}:

buildPythonPackage (finalAttrs: {
  pname = "nutils-poly";
  version = "1.0.1";

  src = fetchFromGitHub {
    owner = "nutils";
    repo = "poly-py";
    tag = "v${finalAttrs.version}";
    hash = "sha256-dxFv4Az3uz6Du5dk5KZJ+unVbt3aZjxXliAQZhmBWDM=";
  };

  nativeBuildInputs = [ rustPlatform.cargoSetupHook ];
  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [ libiconv ];
  nativeCheckInputs = [ unittestCheckHook ];
  build-system = [ rustPlatform.maturinBuildHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit (finalAttrs) pname version src;
    hash = "sha256-3UBQJfMPVo37V7mJnN9loF1+vKh3JxFJWgynwsOnAg4=";
  };

  dependencies = [ numpy ];
  pyproject = true;
  pythonImportsCheck = [ "nutils_poly" ];

  meta = {
    description = "Low-level functions for evaluating and manipulating polynomials";
    homepage = "https://github.com/nutils/poly-py";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomasajt ];
  };
})
