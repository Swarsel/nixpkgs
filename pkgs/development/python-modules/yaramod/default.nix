{
  lib,
  fetchFromGitHub,
  buildPythonPackage,
  cmake,
  gtest,
  libxcrypt,
  nlohmann_json,
  pybind11,
  pytestCheckHook,
  setuptools,
}:

let
  pog = fetchFromGitHub {
    hash = "sha256-El4WA92t2O/L4wUqH6Xj8w+ANtb6liRwafDhqn8jxjQ=";
    owner = "metthal";
    repo = "pog";
    rev = "b09bbf9cea573ee62aab7eccda896e37961d16cd";
  };
in
buildPythonPackage (finalAttrs: {
  pname = "yaramod";
  version = "4.8.0";

  src = fetchFromGitHub {
    owner = "avast";
    repo = "yaramod";
    tag = "v${finalAttrs.version}";
    hash = "sha256-TSq+5qwENCcmTEqKB7rlE4qzpRYhsH9uC6W+tcDQ2AE=";
  };

  postPatch = ''
    rm -r deps/googletest deps/pog/ deps/pybind11/ deps/json/json.hpp
    cp -r --no-preserve=all ${pog} deps/pog/
    cp -r --no-preserve=all ${nlohmann_json.src}/single_include/nlohmann/json.hpp deps/json/
    cp -r --no-preserve=all ${pybind11.src} deps/pybind11/
    cp -r --no-preserve=all ${gtest.src} deps/googletest/

    substituteInPlace deps/pog/deps/fmt/fmt/CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 3.1.0)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [
    cmake
    pog
  ];

  buildInputs = [ libxcrypt ];
  env.ENV_YARAMOD_BUILD_WITH_UNIT_TESTS = true;

  nativeCheckInputs = [
    gtest
    pytestCheckHook
  ];

  build-system = [ setuptools ];
  dontUseCmakeConfigure = true;
  enabledTestPaths = [ "tests/" ];
  pyproject = true;
  pythonImportsCheck = [ "yaramod" ];

  meta = {
    description = "Parsing of YARA rules into AST and building new rulesets in C++";
    homepage = "https://github.com/avast/yaramod";
    changelog = "https://github.com/avast/yaramod/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ msm ];
  };
})
