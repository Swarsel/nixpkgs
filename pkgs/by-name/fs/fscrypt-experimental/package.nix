{
  lib,
  fetchFromGitHub,
  buildGoModule,
  fscrypt-experimental,
  gnum4,
  pam,
}:

# Don't use this for anything important yet!

buildGoModule rec {
  pname = "fscrypt";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "google";
    repo = "fscrypt";
    rev = "v${version}";
    hash = "sha256-iz/lkLDHJkyAHqSlzr8vbcbZv9N/c1evNufeAFNdcag=";
  };

  postPatch = ''
    substituteInPlace Makefile \
      --replace 'TAG_VERSION := $(shell git describe --tags)' "" \
      --replace "/usr/local" "$out"
  '';

  nativeBuildInputs = [ gnum4 ];
  buildInputs = [ pam ];
  vendorHash = "sha256-0bCpmwWWTLWsa3P5ERwOCJ1we1sofqqPXy5JlZsqJpk=";

  buildPhase = ''
    runHook preBuild
    make
    runHook postBuild
  '';

  doCheck = false;

  installPhase = ''
    runHook preInstall
    make install
    runHook postInstall
  '';

  meta = {
    inherit (src.meta) homepage;
    description = "High-level tool for the management of Linux filesystem encryption";

    longDescription = ''
      This tool manages metadata, key generation, key wrapping, PAM integration,
      and provides a uniform interface for creating and modifying encrypted
      directories.
    '';

    changelog = "https://github.com/google/fscrypt/releases/tag/v${version}";
    license = lib.licenses.asl20;
    maintainers = [ ];
    platforms = lib.platforms.linux;
    mainProgram = "fscrypt";
  };
}
