{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  obs-studio,
}:

stdenv.mkDerivation rec {
  pname = "obs-advanced-masks";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "FiniteSingularity";
    repo = "obs-advanced-masks";
    tag = "v${version}";
    hash = "sha256-NtmOWKk3eZeRa3TvclZpg4sj8lbOoY8hUhxs1z6kEW4=";
  };

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    obs-studio
  ];

  postInstall = ''
    rm -rf "$out/share"
    mkdir -p "$out/share/obs"
    mv "$out/data/obs-plugins" "$out/share/obs"
    rm -rf "$out/obs-plugins" "$out/data"
  '';

  meta = {
    description = "Advanced Masking Plugin for OBS";
    homepage = "https://github.com/FiniteSingularity/obs-advanced-masks";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ rytswd ];
    platforms = lib.platforms.linux;
    mainProgram = "obs-advanced-masks";
  };
}
