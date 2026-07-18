{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  cups,
  curl,
  libGL,
  ninja,
  pkg-config,
  qt5compat,
  qtbase,
  qtcreator,
  qttools,
  runCommand,
  vulkan-headers,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "qodeassist-plugin";
  version = "0.9.11";

  src = fetchFromGitHub {
    owner = "Palm1r";
    repo = "QodeAssist";
    tag = "v${finalAttrs.version}";
    hash = "sha256-8GU19EWxwxHyjmSVBzTiz5qTrQr5WhLpWowispKUSyQ=";
  };

  outputs = [ "out" ];

  nativeBuildInputs = [
    cmake
    pkg-config
    ninja
    (qttools.override { withClang = true; })
  ];

  buildInputs = [
    cups
    curl
    libGL
    qtbase
    qt5compat
    qtcreator
    vulkan-headers
  ];

  cmakeFlags = [ ];
  installPhase = "mkdir -p $out; cp -R lib $out/";
  dontWrapQtApps = true;

  passthru.tests = {
    test-version = runCommand "${finalAttrs.pname}-test" { } ''
      QT_QPA_PLATFORM="offscreen" ${
        lib.getExe (qtcreator.withPackages [ finalAttrs.finalPackage ])
      } --version > $out
      cat $out | grep 'qodeassist ${finalAttrs.version}'
    '';
  };

  meta = {
    description = "AI-powered coding assistant plugin for Qt Creator";

    longDescription = ''
      QodeAssist is an AI-powered coding assistant plugin for Qt Creator.
      It provides intelligent code completion and suggestions for C++ and QML,
      leveraging large language models through local providers like Ollama.
      Enhance your coding productivity with context-aware AI assistance directly
      in your Qt development environment.
    '';

    homepage = "https://github.com/Palm1r/QodeAssist";
    license = lib.licenses.gpl3Only;
    maintainers = [ lib.maintainers.zatm8 ];
    platforms = qtcreator.meta.platforms;
  };
})
