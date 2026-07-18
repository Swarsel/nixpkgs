{
  lib,
  stdenv,
  fetchFromGitHub,
  bash,
  coreutils,
  gawk,
  makeWrapper,
  nixosTests,
  shellcheck,
  systemd,
  util-linux,
}:

stdenv.mkDerivation {
  pname = "nmtrust";
  version = "0.1.1";

  src = fetchFromGitHub {
    owner = "brett";
    repo = "nmtrust-nix";
    rev = "v0.1.1";
    hash = "sha256-niCbYxeunNxfkM/HEUiMAvwiholR0nmEPqssOOl9Qvo=";
  };

  strictDeps = true;
  nativeBuildInputs = [ makeWrapper ];
  doCheck = true;
  nativeCheckInputs = [ shellcheck ];

  checkPhase = ''
    runHook preCheck
    shellcheck nmtrust.sh
    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 nmtrust.sh $out/bin/nmtrust
    wrapProgram $out/bin/nmtrust \
      --prefix PATH : ${
        lib.makeBinPath [
          bash
          systemd
          coreutils
          gawk
          util-linux
        ]
      }
    runHook postInstall
  '';

  __structuredAttrs = true;
  passthru.tests = { inherit (nixosTests) nmtrust; };

  meta = {
    description = "Declarative network trust management for NixOS";

    longDescription = ''
      nmtrust evaluates the trust state of active NetworkManager connections
      and activates corresponding systemd targets. Services bound to these
      targets start and stop automatically as you move between trusted,
      untrusted, and offline networks.

      A NixOS-native reimplementation of nmtrust by Peter Hogg (pigmonkey).
    '';

    homepage = "https://github.com/brett/nmtrust-nix";
    license = lib.licenses.unlicense;
    maintainers = [ lib.maintainers.brett ];
    platforms = lib.platforms.linux;
    mainProgram = "nmtrust";
  };
}
