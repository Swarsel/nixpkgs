{
  lib,
  stdenv,
  aws-c-common,
  aws-crt-cpp,
  aws-sdk-cpp,
  boost,
  cmake,
  curl,
  freebsd,
  libseccomp,
  mkMesonLibrary,
  nix-util,
  nlohmann_json,
  pkgsStatic,
  sqlite,
  unixtools,
  # Configuration Options
  version,
  busybox-sandbox-shell ? null,
  embeddedSandboxShell ? stdenv.hostPlatform.isStatic,
  sandboxShell ?
    if stdenv.hostPlatform.isLinux then
      "${busybox-sandbox-shell}/bin/busybox"
    else if stdenv.hostPlatform.isFreeBSD then
      "${pkgsStatic.bash}/bin/bash"
    else
      null,
  withAWS ?
    # Default is this way because there have been issues building this dependency
    # TODO: aws-crt-cpp is broken on cygwin, find a good way to check that here
    lib.meta.availableOn stdenv.hostPlatform aws-c-common && !stdenv.hostPlatform.isCygwin,
  withSandboxShell ?
    stdenv.hostPlatform.isLinux
    || (lib.versionAtLeast version "2.35pre" && stdenv.hostPlatform.isFreeBSD),
}:

mkMesonLibrary (finalAttrs: {
  inherit version;
  pname = "nix-store";

  nativeBuildInputs =
    lib.optional embeddedSandboxShell unixtools.hexdump
    ++ lib.optional (withAWS && lib.versionAtLeast version "2.34pre") cmake;

  buildInputs = [
    boost
    curl
    sqlite
  ]
  ++ lib.optional (
    lib.versionAtLeast version "2.35pre" && stdenv.hostPlatform.isFreeBSD
  ) freebsd.libjail
  ++ lib.optional stdenv.hostPlatform.isLinux libseccomp
  # There have been issues building these dependencies
  ++
    lib.optional withAWS
      # Nix >=2.33 doesn't depend on aws-sdk-cpp and only requires aws-crt-cpp for authenticated s3:// requests.
      (if lib.versionAtLeast (lib.versions.majorMinor version) "2.33" then aws-crt-cpp else aws-sdk-cpp);

  propagatedBuildInputs = [
    nix-util
    nlohmann_json
  ];

  mesonFlags = [
    (lib.mesonEnable "seccomp-sandboxing" stdenv.hostPlatform.isLinux)
    (lib.mesonBool "embedded-sandbox-shell" embeddedSandboxShell)
  ]
  ++ lib.optional (lib.versionAtLeast (lib.versions.majorMinor version) "2.33") (
    lib.mesonEnable "s3-aws-auth" withAWS
  )
  ++ lib.optionals withSandboxShell [
    (lib.mesonOption "sandbox-shell" sandboxShell)
  ];

  workDir = ./.;

  meta = {
    platforms = lib.platforms.unix ++ lib.platforms.windows;
  };

})
