{
  lib,
  stdenv,
  fetchFromGitLab,
  installShellFiles,
  libbsd,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "netcat-openbsd";
  version = "1.234-2";

  src = fetchFromGitLab {
    owner = "debian";
    repo = "netcat-openbsd";
    tag = "debian/${finalAttrs.version}";
    hash = "sha256-kA9QzEI4nutQrKonHw+SxWYbuBLtn91edMAk8JBdAhU=";
    domain = "salsa.debian.org";
  };

  postPatch = ''
    for file in $(cat debian/patches/series); do
      patch -p1 < debian/patches/$file
    done
  '';

  strictDeps = true;

  nativeBuildInputs = [
    pkg-config
    installShellFiles
  ];

  buildInputs = [ libbsd ];

  installPhase = ''
    runHook preInstall

    install -Dm755 -t $out/bin nc
    installManPage nc.1

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/nc -h 2> /dev/null
  '';

  meta = {
    description = "TCP/IP swiss army knife. OpenBSD variant";
    homepage = "https://salsa.debian.org/debian/netcat-openbsd";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ artturin ];
    platforms = lib.platforms.unix;
    mainProgram = "nc";
    # never built on aarch64-darwin, x86_64-darwin since first introduction in nixpkgs
    broken = stdenv.hostPlatform.isDarwin;
  };
})
