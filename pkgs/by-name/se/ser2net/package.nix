{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gensio,
  libyaml,
  nix-update-script,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "ser2net";
  version = "4.6.7";

  src = fetchFromGitHub {
    owner = "cminyard";
    repo = "ser2net";
    rev = "v${finalAttrs.version}";
    hash = "sha256-Axo3qa+QoBqFOLkxA6ZnEYu0M1p9LSM9h/oS8JsdwOY=";
  };

  nativeBuildInputs = [
    pkg-config
    autoreconfHook
  ];

  buildInputs = [
    gensio
    libyaml
  ];

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Serial to network connection server";
    homepage = "https://github.com/cminyard/ser2net";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ emantor ];
    platforms = with lib.platforms; linux;
    mainProgram = "ser2net";
  };
})
