{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  doctest,
  libuuid,
  nix-update-script,
  nlohmann_json,
  xtl,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "xeus";
  version = "5.2.4";

  src = fetchFromGitHub {
    owner = "jupyter-xeus";
    repo = "xeus";
    tag = finalAttrs.version;
    hash = "sha256-siQzTu2IYHLbZrgLTbHPt8Ek8vLA/wXB0jx7oXC6d7k=";
  };

  nativeBuildInputs = [
    cmake
    doctest
  ];

  buildInputs = [
    nlohmann_json
    libuuid
  ];

  cmakeFlags = [
    "-DXEUS_BUILD_TESTS=ON"
  ];

  doCheck = true;
  preCheck = "export LD_LIBRARY_PATH=$PWD";
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "C++ implementation of the Jupyter Kernel protocol";
    homepage = "https://xeus.readthedocs.io";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ serge_sans_paille ];
    platforms = lib.platforms.all;
  };
})
