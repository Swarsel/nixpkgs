{
  lib,
  fetchFromGitHub,
  gitUpdater,
  linkFarm,
  makeWrapper,
  rustPlatform,
  tree-sitter-grammars,
  versionCheckHook,
}:

let
  # based on https://github.com/NixOS/nixpkgs/blob/aa07b78b9606daf1145a37f6299c6066939df075/pkgs/development/tools/parsing/tree-sitter/default.nix#L85-L104
  grammarToAttrSet = drv: {
    name = "lib" + (lib.strings.removeSuffix "-grammar" (lib.strings.getName drv)) + ".so";
    path = "${drv}/parser";
  };

  libPath = linkFarm "grammars" (map grammarToAttrSet tree-sitter-grammars.allGrammars);
in
rustPlatform.buildRustPackage rec {
  pname = "diffsitter";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "afnanenayet";
    repo = "diffsitter";
    rev = "v${version}";
    hash = "sha256-ta7JcSPEgpJwieYvtZnNMFvsYvz4FuxthhmKMYe2XUE=";
    fetchSubmodules = false;
  };

  nativeBuildInputs = [
    makeWrapper
  ];

  cargoHash = "sha256-YgVsWiINzEsmUMAi6ttEtXutwNDJA2viXnV5rGdSSxU=";
  doCheck = false;

  postInstall = ''
    # completions are not yet implemented
    # so we can safely remove this without installing the completions
    rm $out/bin/diffsitter_completions

    wrapProgram "$out/bin/diffsitter" \
      --prefix LD_LIBRARY_PATH : "${libPath}"
  '';

  doInstallCheck = true;

  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  buildFeatures = [
    "dynamic-grammar-libs"
  ];

  buildNoDefaultFeatures = true;
  # failures:
  #     tests::diff_hunks_snapshot::_medium_cpp_cpp_false_expects
  #     tests::diff_hunks_snapshot::_medium_cpp_cpp_true_expects
  #     tests::diff_hunks_snapshot::_medium_rust_rs_false_expects
  #     tests::diff_hunks_snapshot::_medium_rust_rs_true_expects
  #     tests::diff_hunks_snapshot::_short_python_py_true_expects
  #     tests::diff_hunks_snapshot::_short_rust_rs_true_expects
  passthru.updateScript = gitUpdater { rev-prefix = "v"; };

  meta = {
    description = "Tree-sitter based AST difftool to get meaningful semantic diffs";
    homepage = "https://github.com/afnanenayet/diffsitter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ bbigras ];
  };
}
