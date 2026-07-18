{
  lib,
  stdenv,
  fetchFromGitHub,
}:
{
  bats-assert = stdenv.mkDerivation (finalAttrs: {
    pname = "bats-assert";
    version = "2.1.0";

    src = fetchFromGitHub {
      owner = "bats-core";
      repo = "bats-assert";
      rev = "v${finalAttrs.version}";
      hash = "sha256-opgyrkqTwtnn/lUjMebbLfS/3sbI2axSusWd5i/5wm4=";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/bats/bats-assert"
      cp load.bash "$out/share/bats/bats-assert"
      cp -r src "$out/share/bats/bats-assert"
      runHook postInstall
    '';

    dontBuild = true;

    meta = {
      description = "Common assertions for Bats";
      homepage = "https://github.com/bats-core/bats-assert";
      license = lib.licenses.cc0;
      maintainers = with lib.maintainers; [ brokenpip3 ];
      platforms = lib.platforms.all;
    };
  });

  bats-detik = stdenv.mkDerivation (finalAttrs: {
    pname = "bats-detik";
    version = "1.3.3";

    src = fetchFromGitHub {
      owner = "bats-core";
      repo = "bats-detik";
      rev = "v${finalAttrs.version}";
      hash = "sha256-NM8/WDiTOJORC6+pAa6tYJC7wnuMH9OP5LBaatXyaYw=";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/bats/bats-detik"
      cp -r lib/* "$out/share/bats/bats-detik"
      runHook postInstall
    '';

    dontBuild = true;

    meta = {
      description = "Library to ease e2e tests of applications in K8s environments";
      homepage = "https://github.com/bats-core/bats-detik";
      license = lib.licenses.mit;
      maintainers = with lib.maintainers; [ brokenpip3 ];
      platforms = lib.platforms.all;
    };
  });

  bats-file = stdenv.mkDerivation (finalAttrs: {
    pname = "bats-file";
    version = "0.4.0";

    src = fetchFromGitHub {
      owner = "bats-core";
      repo = "bats-file";
      rev = "v${finalAttrs.version}";
      hash = "sha256-NJzpu1fGAw8zxRKFU2awiFM2Z3Va5WONAD2Nusgrf4o=";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/bats/bats-file"
      cp load.bash "$out/share/bats/bats-file"
      cp -r src "$out/share/bats/bats-file"
      runHook postInstall
    '';

    dontBuild = true;

    meta = {
      description = "Common filesystem assertions for Bats";
      homepage = "https://github.com/bats-core/bats-file";
      license = lib.licenses.cc0;
      maintainers = with lib.maintainers; [ brokenpip3 ];
      platforms = lib.platforms.all;
    };
  });

  bats-support = stdenv.mkDerivation (finalAttrs: {
    pname = "bats-support";
    version = "0.3.0";

    src = fetchFromGitHub {
      owner = "bats-core";
      repo = "bats-support";
      rev = "v${finalAttrs.version}";
      hash = "sha256-4N7XJS5XOKxMCXNC7ef9halhRpg79kUqDuRnKcrxoeo=";
    };

    installPhase = ''
      runHook preInstall
      mkdir -p "$out/share/bats/bats-support"
      cp load.bash "$out/share/bats/bats-support"
      cp -r src "$out/share/bats/bats-support"
      runHook postInstall
    '';

    dontBuild = true;

    meta = {
      description = "Supporting library for Bats test helpers";
      homepage = "https://github.com/bats-core/bats-support";
      license = lib.licenses.cc0;
      maintainers = with lib.maintainers; [ brokenpip3 ];
      platforms = lib.platforms.all;
    };
  });
}
