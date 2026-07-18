{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  nix-update-script,
  obs-studio,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obs-browser-transition";
  version = "0.1.3";

  src = fetchFromGitHub {
    owner = "exeldro";
    repo = "obs-browser-transition";
    tag = finalAttrs.version;
    hash = "sha256-m5UDqnqipkybXAZqS7c2Sj/mJKrDBkXElyc0I+c1BmE=";
  };

  nativeBuildInputs = [ cmake ];
  buildInputs = [ obs-studio ];

  postInstall = ''
    rm -rf $out/obs-plugins $out/data
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Plugin for OBS Studio to show a browser source during scene transition";
    homepage = "https://github.com/exeldro/obs-browser-transition";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ flexiondotorg ];
    platforms = lib.platforms.linux;
  };
})
