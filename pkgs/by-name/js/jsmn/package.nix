{
  lib,
  stdenv, # for tests
  fetchFromGitHub,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "jsmn";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "zserge";
    repo = "jsmn";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Vv8Cqb+WZZVnmtVZ12JYd5/qUrqLqi4lvNsUyj9NnRQ=";
  };

  strictDeps = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 jsmn.h $out/include/jsmn.h

    runHook postInstall
  '';

  __structuredAttrs = true;
  dontBuild = true;
  dontConfigure = true;

  passthru.tests.suite = stdenv.mkDerivation {
    inherit (finalAttrs) version src;
    pname = "jsmn-tests";
    doCheck = true;

    checkPhase = ''
      runHook preCheck

      make test

      runHook postCheck
    '';

    installPhase = ''
      runHook preInstall

      touch $out

      runHook postInstall
    '';

    dontBuild = true;
    dontConfigure = true;
  };

  meta = {
    description = "Minimalistic JSON parser in C";
    homepage = "https://github.com/zserge/jsmn";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ BatteredBunny ];
    platforms = lib.platforms.all;
  };
})
