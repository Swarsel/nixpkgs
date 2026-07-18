{
  lib,
  stdenv,
  fetchFromSourcehut,
  meson,
  ninja,
  pkg-config,
  scdoc,
  systemd,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "poweralertd";
  version = "0.3.0";

  src = fetchFromSourcehut {
    owner = "~kennylevinsen";
    repo = "poweralertd";
    rev = finalAttrs.version;
    hash = "sha256-WzqThv3Vu8R+g6Bn8EfesRk18rchCvw/UMPwbn9YC80=";
  };

  outputs = [
    "out"
    "man"
  ];

  postPatch = ''
    substituteInPlace meson.build --replace-fail "systemd.get_pkgconfig_variable('systemduserunitdir')" "'${placeholder "out"}/lib/systemd/user'"
  '';

  nativeBuildInputs = [
    meson
    ninja
    pkg-config
  ];

  buildInputs = [
    systemd
  ];

  depsBuildBuild = [
    scdoc
    pkg-config
  ];

  meta = {
    description = "UPower-powered power alerter";
    homepage = "https://git.sr.ht/~kennylevinsen/poweralertd";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ thibautmarty ];
    platforms = lib.platforms.linux;
    mainProgram = "poweralertd";
  };
})
