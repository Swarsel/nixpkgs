{
  lib,
  fetchFromGitHub,
  cmake,
  ctestCheckHook,
  gtest,
  llvmPackages,
  ninja,
  nix-update-script,
  versionCheckHook,
}:

# redumper is using C++ modules, this requires latest C++20 compiler and build tools
llvmPackages.libcxxStdenv.mkDerivation (finalAttrs: {
  pname = "redumper";
  version = "726";

  src = fetchFromGitHub {
    owner = "superg";
    repo = "redumper";
    tag = "b${finalAttrs.version}";
    hash = "sha256-887r4SatrybmG4tSJRLpOQNcxwvMVF0iTZoWWNQ4m8A=";
  };

  patches = [
    ./remove-static-linking.patch
  ];

  strictDeps = true;

  nativeBuildInputs = [
    cmake
    ctestCheckHook
    ninja
    llvmPackages.clang-tools
  ];

  # https://github.com/superg/redumper/blob/main/.github/workflows/cmake.yml
  cmakeFlags = [
    (lib.cmakeFeature "REDUMPER_VERSION_BUILD" "${finalAttrs.src.tag}")
    (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_GOOGLETEST" "${gtest.src}")
  ];

  doCheck = true;
  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];
  __structuredAttrs = true;

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version-regex"
      "b(.*)"
    ];
  };

  meta = {
    description = "Low level CD dumper utility";
    homepage = "https://github.com/superg/redumper";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ hughobrien ];
    platforms = lib.platforms.unix;
    mainProgram = "redumper";
  };
})
