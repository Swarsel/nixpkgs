{
  lib,
  fetchFromGitHub,
  llvmPackages,
  python3Packages,
}:

let
  inherit (llvmPackages) clang-unwrapped;
in

python3Packages.buildPythonApplication (finalAttrs: {
  pname = "whatstyle";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "mikr";
    repo = "whatstyle";
    tag = "v${finalAttrs.version}";
    hash = "sha256-4LCZAEUQFPl4CBPeuqsodiAlwd8uBg+SudF5d+Vz4Gc=";
  };

  # Fix references to previous version, to avoid confusion:
  postPatch = ''
    substituteInPlace setup.py --replace-fail 0.1.9 ${finalAttrs.version}
    substituteInPlace whatstyle.py --replace-fail 0.1.9 ${finalAttrs.version}
  '';

  doCheck = false; # 3 or 4 failures depending on version, haven't investigated.

  nativeCheckInputs = [
    clang-unwrapped # clang-format
  ];

  format = "setuptools";

  meta = {
    description = "Find a code format style that fits given source files";
    homepage = "https://github.com/mikr/whatstyle";
    license = lib.licenses.mit;
    maintainers = [ ];
    platforms = lib.platforms.all;
    mainProgram = "whatstyle";
  };
})
