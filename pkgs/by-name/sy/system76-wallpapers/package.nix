{
  lib,
  fetchFromGitHub,
  imagemagick,
  nix-update-script,
  stdenvNoCC,
}:

stdenvNoCC.mkDerivation {
  pname = "system76-wallpapers";
  version = "0-unstable-2025-10-27";

  src = fetchFromGitHub {
    owner = "pop-os";
    repo = "system76-wallpapers";
    rev = "c9a5b3943e7fdab96e1cbbdbca1a7ebca371fc3c";
    hash = "sha256-2M6cFuQMjG0edhZIuxw0LLLoau6Np9igVG22bhBUE3Y=";
    fetchLFS = true;
    forceFetchGit = true;
  };

  nativeBuildInputs = [ imagemagick ];
  makeFlags = [ "prefix=$(out)" ];

  prePatch = ''
    cp ${./Makefile} Makefile
  '';

  passthru.updateScript = nix-update-script { extraArgs = [ "--version=branch" ]; };

  meta = {
    description = "Wallpapers for System76 products";
    homepage = "https://system76.com/";

    license = with lib.licenses; [
      cc-by-sa-40
    ];

    maintainers = with lib.maintainers; [ pandapip1 ];
    platforms = lib.platforms.all;
  };
}
