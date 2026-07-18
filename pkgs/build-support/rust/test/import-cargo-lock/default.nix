{
  callPackage,
  maturin,
  python3Packages,
  writers,
}:

# Build like this from nixpkgs root:
# $ nix-build -A tests.importCargoLock
{
  basic = callPackage ./basic { };
  basicDynamic = callPackage ./basic-dynamic { };
  gitDependency = callPackage ./git-dependency { };
  gitDependencyBranch = callPackage ./git-dependency-branch { };
  gitDependencyRev = callPackage ./git-dependency-rev { };

  gitDependencyRevNonWorkspaceNestedCrate =
    callPackage ./git-dependency-rev-non-workspace-nested-crate
      { };

  gitDependencyTag = callPackage ./git-dependency-tag { };

  gitDependencyWorkspaceInheritance = callPackage ./git-dependency-workspace-inheritance {
    replaceWorkspaceValues = writers.writePython3 "replace-workspace-values" {
      flakeIgnore = [
        "E501"
        "W503"
      ];

      libraries = with python3Packages; [
        tomli
        tomli-w
      ];
    } (builtins.readFile ../../replace-workspace-values.py);
  };

  maturin = maturin.tests.pyo3;
  v1 = callPackage ./v1 { };
}
