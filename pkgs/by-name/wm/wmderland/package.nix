{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  libnotify,
  libx11,
  nixosTests,
  xorgproto,
}:

stdenv.mkDerivation {
  pname = "wmderland";
  version = "unstable-2020-07-17";

  src = fetchFromGitHub {
    owner = "aesophor";
    repo = "wmderland";
    rev = "a40a3505dd735b401d937203ab6d8d1978307d72";
    sha256 = "0npmlnybblp82mfpinjbz7dhwqgpdqc1s63wc1zs8mlcs19pdh98";
  };

  patches = [ ./0001-remove-flto.patch ];

  postPatch = ''
    substituteInPlace src/util.cc \
      --replace "notify-send" "${libnotify}/bin/notify-send"
  '';

  nativeBuildInputs = [
    cmake
  ];

  buildInputs = [
    libx11
    xorgproto
  ];

  postInstall = ''
    install -Dm0644 -t $out/share/wmderland/contrib $src/example/config
    install -Dm0644 -t $out/share/xsessions $src/example/wmderland.desktop
  '';

  cmakeBuildType = "MinSizeRel";

  passthru = {
    providedSessions = [ "wmderland" ];
    tests.basic = nixosTests.wmderland;
  };

  meta = {
    description = "Modern and minimal X11 tiling window manager";
    homepage = "https://github.com/aesophor/wmderland";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ takagiy ];
    platforms = libx11.meta.platforms;
    mainProgram = "wmderland";
  };
}
