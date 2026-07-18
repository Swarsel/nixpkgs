{
  lib,
  stdenv,
  fetchFromGitHub,
  catch2_3,
  cmake,
  fmt,
  ninja,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "mcl-cpp-utility-lib";
  version = "0.1.14";

  src = fetchFromGitHub {
    owner = "azahar-emu";
    repo = "mcl";
    tag = finalAttrs.version;
    hash = "sha256-7lHOjlUvCQsct/pijn0M0OOG5LpExmXwB6kH+ostA2I=";
  };

  nativeBuildInputs = [
    cmake
    ninja
  ];

  buildInputs = [
    fmt
  ];

  doCheck = true;

  checkInputs = [
    catch2_3
  ];

  checkPhase = ''
    tests/mcl-tests
  '';

  meta = {
    description = "Collection of C++20 utilities which is common to a number of merry's projects";
    homepage = "https://github.com/azahar-emu/mcl";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ marcin-serwin ];
    platforms = lib.platforms.all;
  };
})
