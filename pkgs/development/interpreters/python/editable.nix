{
  lib,
  buildPythonPackage,
  hatchling,
  tomli-w,
}:
{
  pname,
  # Editable root as string.
  # Environment variables will be expanded at runtime using os.path.expandvars.
  root,
  version,
  # PEP-518 build-system https://peps.python.org/pep-518
  build-system ? [ ],
  # Python dependencies
  dependencies ? [ ],
  # Arguments passed on verbatim to buildPythonPackage
  derivationArgs ? { },
  entry-points ? { },
  gui-scripts ? { },
  meta ? { },
  optional-dependencies ? { },
  passthru ? { },
  # PEP-621 entry points https://peps.python.org/pep-0621/#entry-points
  scripts ? { },
}:

# Create a PEP-660 (https://peps.python.org/pep-0660/) editable package pointing to an impure location outside the Nix store.
# The primary use case of this function is to enable local development workflows where the local package is installed into a virtualenv-like environment using withPackages.

assert lib.isString root;
let
  # In editable mode build-system's are considered to be runtime dependencies.
  dependencies' = dependencies ++ build-system;

  pyprojectContents = {
    # Build editable package using hatchling
    build-system = {
      build-backend = "hatchling.build";
      requires = [ "hatchling" ];
    };

    # PEP-621 project table
    project = {
      inherit
        version
        scripts
        gui-scripts
        entry-points
        ;

      dependencies = map lib.getName dependencies';
      name = pname;
      optional-dependencies = lib.mapAttrs (_: map lib.getName) optional-dependencies;
    };

    # Allow empty package
    tool.hatch.build.targets.wheel.bypass-selection = true;
    # Include our editable pointer file in build
    tool.hatch.build.targets.wheel.force-include."_${pname}.pth" = "_${pname}.pth";
  };

in
buildPythonPackage (
  {
    inherit
      pname
      version
      optional-dependencies
      passthru
      meta
      ;

    build-system = [ hatchling ];
    dependencies = dependencies';
    pyproject = true;

    unpackPhase = ''
      python -c "import json, os, tomli_w; attrs = json.load(open(os.environ['NIX_ATTRS_JSON_FILE'], 'r')); print(tomli_w.dumps(attrs['pyprojectContents']))" > pyproject.toml
      echo 'import os.path, sys; sys.path.insert(0, os.path.expandvars("${root}"))' > _${pname}.pth
    '';
  }
  // derivationArgs
  // {
    inherit pyprojectContents;
    # Note: Using formats.toml generates another intermediary derivation that needs to be built.
    # We inline the same functionality for better UX.
    nativeBuildInputs = (derivationArgs.nativeBuildInputs or [ ]) ++ [ tomli-w ];
    __structuredAttrs = true;
    preferLocalBuild = true;
  }
)
