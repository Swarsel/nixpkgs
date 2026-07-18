{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libvncserver,
  obs-studio,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "obs-vnc";
  version = "0.6.2";

  src = fetchFromGitHub {
    owner = "norihiro";
    repo = "obs-vnc";
    tag = finalAttrs.version;
    hash = "sha256-bveTfyhHH7RAM24Lp0mWlt52ao9Rn6vCuKjfQH+B8Rw=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libvncserver
    obs-studio
  ];

  postInstall = ''
    mkdir $out/lib $out/share
    mv $out/obs-plugins/64bit $out/lib/obs-plugins
    rm -rf $out/obs-plugins
    mv $out/data $out/share/obs
  '';

  meta = {
    description = "VNC viewer integrated into OBS Studio as a source plugin";
    homepage = "https://github.com/norihiro/obs-vnc";
    license = lib.licenses.gpl2Only;
    maintainers = with lib.maintainers; [ flexiondotorg ];
    platforms = lib.platforms.linux;
  };
})
