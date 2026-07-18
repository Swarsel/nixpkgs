{
  lib,
  ast-grep,
  buildPythonPackage,
  nix-update-script,
  pytestCheckHook,
  rustPlatform,
}:
buildPythonPackage {
  inherit (ast-grep) version src cargoDeps;
  pname = "ast-grep-py";

  nativeBuildInputs = with rustPlatform; [
    cargoSetupHook
    maturinBuildHook
  ];

  nativeCheckInputs = [ pytestCheckHook ];
  buildAndTestSubdir = "crates/pyo3";

  prePatch = ''
    substituteInPlace ./crates/pyo3/tests/test_register_lang.py \
      --replace-fail '../..' ${ast-grep.src}
  '';

  pyproject = true;
  pythonImportsCheck = [ "ast_grep_py" ];
  passthru.updateScript = nix-update-script { };

  meta = {
    inherit (ast-grep.meta)
      description
      homepage
      changelog
      license
      ;

    maintainers = with lib.maintainers; [
      nezia
    ];
  };
}
