{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  readline,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "microcom";
  version = "2025.11.0";

  src = fetchFromGitHub {
    owner = "pengutronix";
    repo = "microcom";
    rev = "v${finalAttrs.version}";
    hash = "sha256-drQpUOl+QLBvwT++bEBk9Bt+tTQxrnFgfuoGIW5Bcyw=";
  };

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = [ readline ];

  meta = {
    inherit (finalAttrs.src.meta) homepage;

    description = "Minimalistic terminal program for communicating
    with devices over a serial connection";

    license = lib.licenses.gpl2;
    maintainers = with lib.maintainers; [ emantor ];
    platforms = with lib.platforms; linux;
    mainProgram = "microcom";
  };
})
