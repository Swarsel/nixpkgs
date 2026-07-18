{
  lib,
  stdenv,
  fetchFromGitHub,
  asciidoctor,
  cmake,
  eigen,
  freetype,
  ftgl,
  glew,
  glib,
  installShellFiles,
  libgit2,
  libjpeg,
  libpng,
  libsigcxx,
  libvorbis,
  libx11,
  libxml2,
  openal,
  pkg-config,
  python3,
  wrapGAppsHook3,
  wxwidgets_3_2,
  zlib,
  buildPlugins ? true,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "darkradiant";
  version = "3.9.0";

  src = fetchFromGitHub {
    owner = "codereader";
    repo = "DarkRadiant";
    tag = finalAttrs.version;
    hash = "sha256-y0VzTnHobW36/25/nTV49OKnUMpnsjImioMdNKoTyYA=";
  };

  postPatch = ''
    substituteInPlace radiantcore/CMakeLists.txt \
      --replace-fail "\$ORIGIN/.." "$out/lib/darkradiant"
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    asciidoctor
    wrapGAppsHook3
    wxwidgets_3_2
    installShellFiles
  ];

  buildInputs = [
    zlib
    libjpeg
    wxwidgets_3_2
    libxml2
    libsigcxx
    libpng
    openal
    libvorbis
    eigen
    ftgl
    freetype
    glew
    glib
    libgit2
    python3
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [ libx11 ];

  cmakeFlags = [
    # Disabling dynamic rpath, otherwise it will not found the needed libraries within $out/lib/darkradiant
    (lib.cmakeBool "ENABLE_RELOCATION" false)
    (lib.cmakeBool "ENABLE_DM_PLUGINS" buildPlugins)
  ];

  doCheck = true;

  postInstall = ''
    installManPage ../man/darkradiant.1
  '';

  meta = {
    description = "Open-source level editor for Doom 3 and The Dark Mod";
    homepage = "https://github.com/codereader/DarkRadiant";
    changelog = "https://github.com/codereader/DarkRadiant/releases";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ theobori ];
    platforms = lib.platforms.unix;
    mainProgram = "darkradiant";
    broken = stdenv.hostPlatform.isDarwin;
  };
})
