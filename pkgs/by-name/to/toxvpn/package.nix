{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libcap,
  libsodium,
  libtoxcore,
  nlohmann_json,
  systemd,
  zeromq,
}:

stdenv.mkDerivation {
  pname = "toxvpn";
  version = "0-unstable-2024-08-21";

  src = fetchFromGitHub {
    owner = "cleverca22";
    repo = "toxvpn";
    rev = "c727451eb871b43855b825ff93dc48fa0d3320b6";
    sha256 = "sha256-UncU0cpoyy9Z0TCChGmaHpyhW9ctz32gU7n3hgpOEwU=";
  };

  postPatch = ''
    substituteInPlace CMakeLists.txt \
      --replace-fail "cmake_minimum_required(VERSION 2.6)" "cmake_minimum_required(VERSION 3.10)"
  '';

  nativeBuildInputs = [ cmake ];

  buildInputs = [
    libtoxcore
    nlohmann_json
    libsodium
    zeromq
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libcap
    systemd
  ];

  cmakeFlags = lib.optionals stdenv.hostPlatform.isLinux [ "-DSYSTEMD=1" ];
  postInstall = "cp ${./bootstrap.json} $out/share/toxvpn/";
  doInstallCheck = true;
  installCheckPhase = "$out/bin/toxvpn -h";

  meta = {
    description = "Powerful tool that allows one to make tunneled point to point connections over Tox";
    homepage = "https://github.com/cleverca22/toxvpn";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      cleverca22
      craigem
      obadz
      toonn
    ];

    platforms = lib.platforms.unix;
  };
}
