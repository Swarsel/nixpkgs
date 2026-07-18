{
  lib,
  stdenv,
  fetchFromGitHub,
  boost,
  cmake,
  curl,
  fetchFromCodeberg,
  gitUpdater,
  meson,
  ninja,
  nixVersions,
  nlohmann_json,
  openpbs,
  pkg-config,
  slurm,
  symlinkJoin,
}:
let
  restclient-cpp = fetchFromGitHub {
    hash = "sha256-9//KssNRD7OJFNFdXgzsu7rKP/Nlb4wtmBjfhOt2Vgw=";
    owner = "mrtazz";
    repo = "restclient-cpp";
    rev = "3356f816b161279cfbe318c45cb07c07fb8de6df";
  };
  slurmJoined = symlinkJoin {
    name = "slurm";

    paths = [
      slurm
      slurm.dev
    ];
  };
  nix = nixVersions.nix_2_34;
in
stdenv.mkDerivation rec {
  pname = "nix-scheduler-hook";
  version = "0.8.0";

  src = fetchFromCodeberg {
    owner = "lisanna";
    repo = "nix-scheduler-hook";
    tag = "v${version}";
    hash = "sha256-QMenfkNvn6bBGdu+d6i533/CkHNS7Tmr40cgl/ks5dk=";
  };

  nativeBuildInputs = [
    meson
    cmake
    ninja
    pkg-config
  ];

  buildInputs = [
    boost
    curl
    nix.libs.nix-util
    nix.libs.nix-store
    nix.libs.nix-main
    nlohmann_json
    openpbs
    slurmJoined
  ];

  installPhase = ''
    mkdir -p $out/bin
    mv nsh $out/bin
    mkdir -p $out/lib
    shopt -s extglob
    mv subprojects/restclient-cpp/librestclient_cpp.so!(*p) $out/lib
  '';

  postUnpack = ''
    mkdir $sourceRoot/subprojects
    cp -r ${restclient-cpp} $sourceRoot/subprojects/restclient-cpp
  '';

  sourceRoot = "source/src";

  passthru = {
    updateScript = gitUpdater {
      rev-prefix = "v";
    };
  };

  meta = {
    inherit (nix.meta) platforms;
    description = "Nix build hook that forwards builds to job schedulers";
    homepage = "https://github.com/lisanna-dettwyler/nix-scheduler-hook";
    license = lib.licenses.lgpl21;
    maintainers = with lib.maintainers; [ lisanna-dettwyler ];
    mainProgram = "nsh";
  };
}
