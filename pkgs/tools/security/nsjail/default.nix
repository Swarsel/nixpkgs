{
  lib,
  stdenv,
  fetchFromGitHub,
  autoconf,
  bison,
  flex,
  installShellFiles,
  libnl,
  libtool,
  pkg-config,
  protobuf,
  protobufc,
  shadow,
  which,
}:

stdenv.mkDerivation rec {
  pname = "nsjail";
  version = "3.6";

  src = fetchFromGitHub {
    owner = "google";
    repo = "nsjail";
    rev = version;
    hash = "sha256-4fFXPwfPErve5CkVBtjPd1In8eEDby/RhuyW952YW7Y=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    autoconf
    bison
    flex
    installShellFiles
    libtool
    pkg-config
    which
  ];

  buildInputs = [
    libnl
    protobuf
    protobufc
  ];

  env.NIX_CFLAGS_COMPILE = toString [ "-Wno-error" ];

  preBuild = ''
    makeFlagsArray+=(USER_DEFINES='-DNEWUIDMAP_PATH=${shadow}/bin/newuidmap -DNEWGIDMAP_PATH=${shadow}/bin/newgidmap')
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 nsjail "$out/bin/nsjail"
    installManPage nsjail.1
    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Light-weight process isolation tool, making use of Linux namespaces and seccomp-bpf syscall filters";
    homepage = "https://nsjail.dev/";
    changelog = "https://github.com/google/nsjail/releases/tag/${version}";
    license = lib.licenses.asl20;

    maintainers = with lib.maintainers; [
      arturcygan
      bosu
    ];

    platforms = lib.platforms.linux;
    mainProgram = "nsjail";
  };
}
