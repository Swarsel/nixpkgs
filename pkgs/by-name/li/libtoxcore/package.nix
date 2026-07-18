{
  lib,
  stdenv,
  fetchFromGitHub,
  check,
  cmake,
  libconfig,
  libopus,
  libsodium,
  libvpx,
  ncurses,
  pkg-config,
}:

let
  buildToxAV = !stdenv.hostPlatform.isAarch32;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "libtoxcore";
  version = "0.2.23";

  src = fetchFromGitHub {
    owner = "TokTok";
    repo = "c-toxcore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-yII4U+PCkQax7d2ZgTClK+mMypZhVPjEcKDdxHcBf6Y=";
    fetchSubmodules = true;
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    libsodium
    ncurses
    libconfig
  ]
  ++ lib.optionals buildToxAV [
    libopus
    libvpx
  ];

  cmakeFlags = [
    (lib.cmakeBool "DHT_BOOTSTRAP" true)
    (lib.cmakeBool "BOOTSTRAP_DAEMON" true)
  ]
  ++ lib.optional buildToxAV (lib.cmakeBool "MUST_BUILD_TOXAV" true);

  doCheck = true;
  nativeCheckInputs = [ check ];

  postInstall = ''
    substituteInPlace $out/lib/pkgconfig/toxcore.pc \
      --replace '=''${prefix}/' '=' \

  '';

  # We might be getting the wrong pkg-config file anyway:
  # https://github.com/TokTok/c-toxcore/issues/2334
  meta = {
    description = "P2P FOSS instant messaging application aimed to replace Skype";
    homepage = "https://tox.chat";
    license = lib.licenses.gpl3Plus;

    maintainers = with lib.maintainers; [
      peterhoeg
      zatm8
    ];

    platforms = lib.platforms.all;
  };
})
