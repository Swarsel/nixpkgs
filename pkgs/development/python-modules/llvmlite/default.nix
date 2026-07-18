{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  isPyPy,
  libxml2,
  llvm_20,
  ninja,
  # tests
  pytestCheckHook,
  setuptools,
  withStaticLLVM ? true,
}:

let
  llvm = llvm_20;
in

buildPythonPackage rec {
  pname = "llvmlite";
  version = "0.47.0";

  src = fetchFromGitHub {
    owner = "numba";
    repo = "llvmlite";
    tag = "v${version}";
    hash = "sha256-YEIdIdbk19JHYtgL2gWjnAUYu13CH+7ikoyBUkOPpws=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [ llvm ] ++ lib.optionals withStaticLLVM [ libxml2.dev ];
  env.LLVMLITE_SHARED = !withStaticLLVM;
  nativeCheckInputs = [ pytestCheckHook ];

  # https://github.com/NixOS/nixpkgs/issues/255262
  preCheck = ''
    cd $out
  '';

  build-system = [ setuptools ];
  disabled = isPyPy;
  dontUseCmakeConfigure = true;
  pyproject = true;
  passthru = lib.optionalAttrs (!withStaticLLVM) { inherit llvm; };

  meta = {
    description = "Lightweight LLVM python binding for writing JIT compilers";
    homepage = "http://llvmlite.pydata.org/";
    changelog = "https://github.com/numba/llvmlite/blob/v${version}/CHANGE_LOG";
    license = lib.licenses.bsd2;
    downloadPage = "https://github.com/numba/llvmlite";
  };
}
