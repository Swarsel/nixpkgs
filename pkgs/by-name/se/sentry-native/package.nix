{
  lib,
  stdenv,
  fetchFromGitHub,
  breakpad,
  cmake,
  curl,
  pkg-config,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "sentry-native";
  version = "0.15.3";

  src = fetchFromGitHub {
    owner = "getsentry";
    repo = "sentry-native";
    tag = finalAttrs.version;
    hash = "sha256-9UwF8B1dd4RhboMgkZCHI3UqAm8aZAhgLo9VzjwlW/I=";
  };

  nativeBuildInputs = [
    cmake
    pkg-config
  ];

  buildInputs = [
    curl
    breakpad
  ];

  cmakeFlags = [
    "-DSENTRY_BREAKPAD_SYSTEM=On"
    "-DSENTRY_BACKEND=breakpad"
  ];

  cmakeBuildType = "RelWithDebInfo";

  meta = {
    description = "Sentry SDK for C, C++ and native applications";
    homepage = "https://github.com/getsentry/sentry-native";
    changelog = "https://github.com/getsentry/sentry-native/blob/${finalAttrs.version}/CHANGELOG.md";
    license = lib.licenses.mit;

    maintainers = with lib.maintainers; [
      wheelsandmetal
      daniel-fahey
    ];

    platforms = lib.platforms.linux;
  };
})
