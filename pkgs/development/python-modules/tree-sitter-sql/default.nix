{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  # build-system
  setuptools,
  #optional-dependencies
  tree-sitter,
  tree-sitter-sql,
}:
buildPythonPackage rec {
  pname = "tree-sitter-sql";
  version = "0.3.11";

  src = fetchFromGitHub {
    owner = "DerekStride";
    repo = "tree-sitter-sql";
    tag = "v${version}";
    hash = "sha256-efeDAUgCwV9UBXbLyZ1a4Rwcvr/+wke8IzkxRUQnddM=";
  };

  build-system = [
    setuptools
  ];

  optional-dependencies = {
    core = [
      tree-sitter
    ];
  };

  postUnpack = ''
    cp -rf ${tree-sitter-sql.passthru.parsers}/* $sourceRoot
  '';

  pyproject = true;
  pythonImportsCheck = [ "tree_sitter_sql" ];

  passthru = {
    # As mentioned in https://github.com/DerekStride/tree-sitter-sql README
    # generated tree sitter parser files necessary for compilation
    # are separately distributed on the gh-pages branch
    parsers = fetchFromGitHub {
      hash = "sha256-p60nphbSN+O5fOlL06nw0qgQFpmvoNCTmLzDvUC/JGs=";
      owner = "DerekStride";
      repo = "tree-sitter-sql";
      rev = "9853b887c5e4309de273922b681cc7bc09e30c78/gh-pages";
    };
  };

  meta = {
    description = "Sql grammar for tree-sitter";
    homepage = "https://github.com/DerekStride/tree-sitter-sql";
    changelog = "https://github.com/DerekStride/tree-sitter-sql/releases/tag/${src.tag}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ pcboy ];
  };
}
