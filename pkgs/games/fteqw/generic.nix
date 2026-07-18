{
  lib,
  stdenv,
  fetchFromGitHub,
  buildFlags,
  buildInputs,
  description,
  libopus,
  libxrandr,
  pname,
  nativeBuildInputs ? [ ],
  postFixup ? "",
  releaseFile ? pname,
  ...
}:

stdenv.mkDerivation {
  inherit
    pname
    buildFlags
    buildInputs
    nativeBuildInputs
    postFixup
    ;

  version = "0-unstable-2025-06-25";

  src = fetchFromGitHub {
    owner = "fte-team";
    repo = "fteqw";
    rev = "41f35720eda2d1e54d039975db28f46d68a963cb";
    hash = "sha256-g8dKNRHAZvNfCT3ciDSyKJVqjENml39k26NqkP7sQvA=";
  };

  postPatch = ''
    substituteInPlace ./engine/Makefile \
      --replace "I/usr/include/opus" "I${libopus.dev}/include/opus"
    substituteInPlace ./engine/gl/gl_vidlinuxglx.c \
      --replace 'Sys_LoadLibrary("libXrandr"' 'Sys_LoadLibrary("${libxrandr}/lib/libXrandr.so"'
  '';

  makeFlags = [
    "PKGCONFIG=$(PKG_CONFIG)"
    "-C"
    "engine"
  ];

  installPhase = ''
    runHook preInstall

    install -Dm755 engine/release/${releaseFile} $out/bin/${pname}

    runHook postInstall
  '';

  enableParallelBuilding = true;

  meta = {
    inherit description;

    longDescription = ''
      FTE is a game engine baed on QuakeWorld able to
      play games such as Quake 1, 2, 3, and Hexen 2.
      It includes various features such as extended map
      limits, vulkan and OpenGL renderers, a dedicated
      server, and fteqcc, for easier QuakeC development
    '';

    homepage = "https://fteqw.org";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ necrophcodr ];
    platforms = lib.platforms.linux;
  };
}
