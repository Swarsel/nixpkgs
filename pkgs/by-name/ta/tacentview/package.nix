{
  lib,
  stdenv,
  fetchFromGitHub,
  autoPatchelfHook,
  cmake,
  installShellFiles,
  libGL,
  libx11,
  libxcb,
  ninja,
  tacent,
  zenity,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "tacentview";
  version = "1.0.46-unstable-2025-10-12";

  src = fetchFromGitHub {
    owner = "bluescan";
    repo = "tacentview";
    rev = "51569b34ecd3dac9c40106b92deceb4b56feb5de";
    hash = "sha256-SblGqUiwYg+Bk17H41R3ytG2SQH/YfrYskyZOi5QSIc=";
  };

  nativeBuildInputs = [
    cmake
    ninja
    installShellFiles
    autoPatchelfHook
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    tacent
    libx11
    libxcb
    zenity
  ];

  cmakeFlags = [
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_TACENT" "${tacent.src}")
    (lib.cmakeBool "PACKAGE_NIX" true)
  ];

  installPhase = ''
    runHook preInstall

    installBin tacentview

    mkdir -p $out/share/tacentview
    cp -r ../Assets $out/share/tacentview/
    cp -r ../Linux/deb_template/usr/share/icons $out/share
    cp -r ../Linux/deb_template/usr/share/applications $out/share

    runHook postInstall
  '';

  runtimeDependencies = [ libGL ];

  meta = {
    description = "Image and texture viewer";
    homepage = "https://github.com/bluescan/tacentview";
    changelog = "https://github.com/bluescan/tacentview/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.isc;
    maintainers = with lib.maintainers; [ PopeRigby ];
    platforms = with lib.platforms; linux ++ windows;
    mainProgram = "tacentview";
  };
})
