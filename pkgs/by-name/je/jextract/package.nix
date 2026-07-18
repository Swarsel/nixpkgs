{
  lib,
  stdenv,
  fetchFromGitHub,
  gradle,
  jdk25,
  llvmPackages,
  makeBinaryWrapper,
}:

stdenv.mkDerivation {
  pname = "jextract";
  version = "0-unstable-2025-11-12";

  src = fetchFromGitHub {
    owner = "openjdk";
    repo = "jextract";
    rev = "91fc954c46fac907cae6cd1417d835208c9df150";
    hash = "sha256-RAK7A0BCFaYe/q1nCdvXk091bhSj9DKxg2uQfABk4eo=";
  };

  patches = [
    ./copy_lib_clang.patch
  ];

  nativeBuildInputs = [
    gradle
    makeBinaryWrapper
  ];

  doCheck = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/opt/
    cp -r ./build/jextract $out/opt/jextract
    makeBinaryWrapper "$out/opt/jextract/bin/jextract" "$out/bin/jextract"

    runHook postInstall
  '';

  gradleCheckTask = "verify";

  gradleFlags = [
    "-Pllvm_home=${lib.getLib llvmPackages.libclang}"
    "-Pjdk_home=${jdk25}"
  ];

  meta = {
    description = "Tool which mechanically generates Java bindings from a native library headers";
    homepage = "https://github.com/openjdk/jextract";
    license = lib.licenses.gpl2Only;

    maintainers = with lib.maintainers; [
      jlesquembre
      sharzy
    ];

    platforms = jdk25.meta.platforms;
    mainProgram = "jextract";
  };
}
