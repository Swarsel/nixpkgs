{
  lib,
  stdenv,
  fetchFromGitHub,
  alure,
  libinput,
  libx11,
  libxtst,
  makeWrapper,
  openal,
  pkg-config,
  legacy ? false,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "bucklespring";
  version = "1.5.1";

  src = fetchFromGitHub {
    owner = "zevv";
    repo = "bucklespring";
    tag = "v${finalAttrs.version}";
    sha256 = "0prhqibivxzmz90k79zpwx3c97h8wa61rk5ihi9a5651mnc46mna";
  };

  nativeBuildInputs = [
    pkg-config
    makeWrapper
  ];

  buildInputs = [
    openal
    alure
  ]
  ++ lib.optionals legacy [
    libxtst
    libx11
  ]
  ++ lib.optionals (!legacy) [ libinput ];

  makeFlags = lib.optionals (!legacy) [ "libinput=1" ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/wav
    cp -r $src/wav $out/share/.
    install -D ./buckle.desktop $out/share/applications/buckle.desktop
    install -D ./buckle $out/bin/buckle
    wrapProgram $out/bin/buckle --add-flags "-p $out/share/wav"

    runHook postInstall
  '';

  meta = {
    description = "Nostalgia bucklespring keyboard sound";

    longDescription = ''
      When built with libinput (wayland or bare console),
      users need to be in the input group to use this:
      <code>users.users.alice.extraGroups = [ "input" ];</code>
    '';

    homepage = "https://github.com/zevv/bucklespring";
    license = lib.licenses.gpl2Only;
    maintainers = [ ];
    platforms = lib.platforms.unix;
    mainProgram = "buckle";
  };
})
