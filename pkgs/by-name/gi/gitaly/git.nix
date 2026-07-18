{
  lib,
  stdenv,
  fetchFromGitLab,
  curl,
  git,
  gitaly,
  meson,
  ninja,
  openssl,
  pcre2,
  pkg-config,
  zlib,
}:
let
  data = lib.importJSON ./git-data.json;
in
stdenv.mkDerivation (finalAttrs: {
  inherit (data) version;
  pname = "gitaly-git";

  src = fetchFromGitLab {
    inherit (data) rev hash;
    owner = "gitlab-org";
    repo = "git";
    fetchSubmodules = true;
  };

  # This is a patch for gitaly, not git
  patches = [
    ./dont-clone-git-repo.patch
  ];

  nativeBuildInputs = [
    git # clones our repo from the store
    meson
    ninja
    pkg-config
  ];

  # git inputs
  buildInputs = [
    openssl
    zlib
    pcre2
    curl
  ];

  buildFlags = [ "install-git" ];
  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    HOME=/build PAGER=cat $out/bin/git config -l
    file $out/bin/git | grep -qv 'too large section header'

    runHook postInstallCheck
  '';

  # The build phase already installs it all
  GIT_PREFIX = placeholder "out";
  GIT_REPO_PATH = finalAttrs.src;
  HOME = "/build";

  # required to support pthread_cancel()
  NIX_LDFLAGS =
    lib.optionalString (stdenv.cc.isGNU && stdenv.hostPlatform.libc == "glibc") "-lgcc_s"
    + lib.optionalString stdenv.hostPlatform.isFreeBSD "-lthr";

  dontInstall = true;
  # Meson and ninja are required to build git, but gitaly doesn't use them
  dontUseMesonConfigure = true;
  dontUseNinjaBuild = true;
  sourceRoot = "source";

  # Use gitaly and their build system as source root
  unpackPhase = ''
    cp -r ${gitaly.src} source
    chmod -R +w source
    git config --global --add safe.directory '*'
  '';

  meta = {
    description = "Distributed version control system - with Gitaly patches";
    homepage = "https://git-scm.com/";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.all;
    teams = [ lib.teams.gitlab ];
  };
})
