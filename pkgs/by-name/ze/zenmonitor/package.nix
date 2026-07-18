{
  lib,
  stdenv,
  fetchFromGitHub,
  gtk3,
  pkg-config,
  wrapGAppsHook3,
}:

stdenv.mkDerivation {
  pname = "zenmonitor";
  version = "1.5.0-unstable-2025-06-12";

  src = fetchFromGitHub {
    owner = "detiam";
    repo = "zenmonitor3";
    rev = "1e1ceec7353dc418578fe8ae56536bfee6adeca3";
    hash = "sha256-q5BeLu0A2XJkJL8ptN4hj/iLhQmpb16QEhOuIhNzVaI=";
  };

  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];

  buildInputs = [ gtk3 ];
  makeFlags = [ "PREFIX=${placeholder "out"}" ];

  meta = {
    description = "Monitoring software for AMD Zen-based CPUs";
    homepage = "https://github.com/detiam/zenmonitor3";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      alexbakker
      artturin
    ];

    platforms = [
      "i686-linux"
      "x86_64-linux"
    ];

    mainProgram = "zenmonitor";
  };
}
