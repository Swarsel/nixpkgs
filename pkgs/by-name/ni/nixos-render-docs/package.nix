{
  lib,
  python3,
  runCommand,
}:

let
  python = python3.override {
    packageOverrides = final: prev: {
      markdown-it-py = prev.markdown-it-py.overridePythonAttrs (_: {
        doCheck = false;
      });

      mdit-py-plugins = prev.mdit-py-plugins.overridePythonAttrs (_: {
        doCheck = false;
      });
    };

    self = python;
  };
in

python.pkgs.buildPythonApplication rec {
  pname = "nixos-render-docs";
  version = "0.0";

  src = lib.cleanSourceWith {
    filter =
      name: type:
      lib.cleanSourceFilter name type
      && !(
        type == "directory"
        && builtins.elem (baseNameOf name) [
          ".pytest_cache"
          ".mypy_cache"
          "__pycache__"
        ]
      );

    src = ./src;
  };

  propagatedBuildInputs = with python.pkgs; [
    markdown-it-py
    mdit-py-plugins
  ];

  nativeCheckInputs = [
    python.pkgs.pytestCheckHook
  ];

  build-system = [
    python.pkgs.setuptools
  ];

  enabledTestPaths = [
    "tests/"
  ];

  pyproject = true;

  pytestFlags = [
    "-vvrP"
  ];

  # NOTE this is a CI test rather than a build-time test because we want to keep the
  # build closures small. mypy has an unreasonably large build closure for docs builds.
  passthru.tests.typing =
    runCommand "${pname}-mypy"
      {
        nativeBuildInputs = [
          (python3.withPackages (
            ps: with ps; [
              mypy
              pytest
              markdown-it-py
              mdit-py-plugins
            ]
          ))
        ];
      }
      ''
        mypy --strict ${src}
        touch $out
      '';

  meta = {
    description = "Renderer for NixOS manual and option docs";
    license = lib.licenses.mit;
    maintainers = [ ];
    mainProgram = "nixos-render-docs";
  };
}
