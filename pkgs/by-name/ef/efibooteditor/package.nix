{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  efivar,
  pkg-config,
  qt6,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "efibooteditor";
  version = "1.5.5";

  src = fetchFromGitHub {
    owner = "Neverous";
    repo = "efibooteditor";
    tag = "v${finalAttrs.version}";
    hash = "sha256-OtNZA2K6Kr4IHnTw0i+evHJmBx9oAGKuU90XtUfXKy0=";
  };

  postPatch = ''
    substituteInPlace misc/org.x.efibooteditor.policy \
      --replace-fail /usr/bin $out/bin
    substituteInPlace misc/EFIBootEditor.desktop \
      --replace-fail "1.0" ${finalAttrs.version} \
      --replace-fail \
        'pkexec efibooteditor' \
        'sh -c "pkexec env DISPLAY=$DISPLAY XAUTHORITY=$XAUTHORITY efibooteditor"'
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
    qt6.qttools
    qt6.wrapQtAppsHook
  ];

  buildInputs = [ zlib ] ++ lib.optional stdenv.hostPlatform.isLinux efivar;
  cmakeFlags = [ "-DQT_VERSION_MAJOR=6" ];

  env = {
    BUILD_VERSION = "v${finalAttrs.version}";
    LANG = "C.UTF8";
  };

  doCheck = true;

  checkPhase = ''
    runHook preCheck

    ctest --output-on-failure

    runHook postCheck
  '';

  postInstall = ''
    install -Dm644 $src/LICENSE.txt $out/share/licenses/efibooteditor/LICENSE
  '';

  cmakeBuildType = "MinSizeRel";

  meta = {
    description = "Boot Editor for (U)EFI based systems";
    homepage = "https://github.com/Neverous/efibooteditor";
    changelog = "https://github.com/Neverous/efibooteditor/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [ phanirithvij ];
    platforms = lib.platforms.linux; # TODO build is broken on darwin
    mainProgram = "efibooteditor";
  };
})
