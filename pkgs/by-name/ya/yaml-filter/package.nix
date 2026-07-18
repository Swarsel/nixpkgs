{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libyaml,
  pkg-config,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "yaml-filter";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "OpenSCAP";
    repo = "yaml-filter";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HDHjOapMFjuDcWW5+opKD2tllbwz4YBw/EI4W7Wf/6g=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2." "cmake_minimum_required(VERSION 3.10"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [ libyaml ];

  meta = {
    description = "YAML document filtering for libyaml";
    homepage = "https://github.com/OpenSCAP/yaml-filter";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tochiaha ];
    platforms = lib.platforms.all;
    mainProgram = "yamlp";
  };
})
