{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  dnsdbq,
  jansson,
  nix-update-script,
  testers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dnsdbq";
  version = "2.6.8";

  src = fetchFromGitHub {
    owner = "dnsdb";
    repo = "dnsdbq";
    rev = "v${finalAttrs.version}";
    hash = "sha256-5Pi8xFZXnU3abIsH9m6xqrQ6NnEtAbhMU6HXsOYP0gg=";
  };

  nativeBuildInputs = [
    curl # curl-config
  ];

  buildInputs = [
    curl
    jansson
  ];

  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp dnsdbq $out/bin
    mkdir -p $out/man/man1
    cp dnsdbq.man $out/man/man1/dnsdbq.1
    runHook postInstall
  '';

  extraOutputsToInstall = [ "man" ];

  passthru = {
    tests = {
      version = testers.testVersion {
        command = "dnsdbq -v";
        package = dnsdbq;
      };
    };

    updateScript = nix-update-script { };
  };

  meta = {
    description = "C99 program that accesses passive DNS database systems";
    homepage = "https://github.com/dnsdb/dnsdbq";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ x123 ];
    platforms = lib.platforms.all;
    mainProgram = "dnsdbq";
  };
})
