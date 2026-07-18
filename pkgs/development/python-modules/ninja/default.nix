{
  lib,
  buildPythonPackage,
  flit-core,
  ninja,
}:

buildPythonPackage {
  inherit (ninja) version;
  inherit (ninja) setupHook;
  pname = "ninja";
  src = ./stub;
  nativeBuildInputs = [ flit-core ];

  preBuild = ''
    cp "${ninja.src}/misc/ninja_syntax.py" ninja/ninja_syntax.py
  '';

  postUnpack = ''
    substituteInPlace "$sourceRoot/pyproject.toml" \
      --subst-var version

    substituteInPlace "$sourceRoot/ninja/__init__.py" \
      --subst-var version \
      --subst-var-by BIN_DIR "${ninja}/bin"
  '';

  pyproject = true;

  pythonImportsCheck = [
    "ninja"
    "ninja.ninja_syntax"
  ];

  meta = {
    description = "Small build system with a focus on speed";

    longDescription = ''
      This is a stub of the ninja package on PyPI that uses the ninja program
      provided by nixpkgs instead of downloading ninja from the web.
    '';

    homepage = "https://github.com/scikit-build/ninja-python-distributions";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      _999eagle
    ];

    mainProgram = "ninja";
  };
}
