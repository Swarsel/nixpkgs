{
  lib,
  fetchurl,
  nix-update-script,
  stdenvNoCC,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "arkenfox-userjs";
  version = "144.0";

  src = fetchurl {
    url = "https://raw.githubusercontent.com/arkenfox/user.js/refs/tags/${finalAttrs.version}/user.js";
    hash = "sha256-5KszxpFImRdc9wNeDlei1/CKyIfY+VfxGZ5+Sbvn4z4=";
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 $src $out/user.js
    install -Dm644 $src $out/user.cfg
    substituteInPlace $out/user.cfg \
      --replace-fail "user_pref" "defaultPref"

    runHook postInstall
  '';

  dontUnpack = true;
  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Comprehensive user.js template for configuration and hardening";
    homepage = "https://github.com/arkenfox/user.js";
    changelog = "https://github.com/arkenfox/user.js/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      linsui
      Guanran928
    ];

    platforms = lib.platforms.all;
  };
})
