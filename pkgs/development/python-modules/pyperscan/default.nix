{
  lib,
  stdenv,
  fetchFromGitHub,
  buildPythonPackage,
  libiconv,
  pytestCheckHook,
  rustPlatform,
  vectorscan,
}:

buildPythonPackage rec {
  pname = "pyperscan";
  version = "0.3.0";

  src = fetchFromGitHub {
    owner = "vlaci";
    repo = "pyperscan";
    rev = "v${version}";
    hash = "sha256-uGZ0XFxnZHSLEWcwoHVd+xMulDRqEIrQ5Lf7886GdlM=";
  };

  nativeBuildInputs = with rustPlatform; [
    bindgenHook
    cargoSetupHook
    maturinBuildHook
  ];

  buildInputs = [ vectorscan ] ++ lib.optional stdenv.hostPlatform.isDarwin libiconv;
  checkInputs = [ pytestCheckHook ];

  cargoDeps = rustPlatform.fetchCargoVendor {
    inherit pname version src;
    hash = "sha256-9kKHLYD0tXMGJFhsCBgO/NpWB4J5QZh0qKIuI3PFn2c=";
  };

  pyproject = true;
  pythonImportsCheck = [ "pyperscan" ];

  meta = {
    description = "Hyperscan binding for Python, which supports vectorscan";
    homepage = "https://vlaci.github.io/pyperscan/";
    changelog = "https://github.com/vlaci/pyperscan/releases/tag/${src.rev}";

    license =
      with lib.licenses;
      OR [
        asl20
        mit
      ];

    maintainers = with lib.maintainers; [
      tnias
      vlaci
    ];

    platforms = lib.platforms.unix;
  };
}
