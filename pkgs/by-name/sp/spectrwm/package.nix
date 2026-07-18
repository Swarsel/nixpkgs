{
  lib,
  stdenv,
  fetchFromGitHub,
  curl,
  jq,
  libbsd,
  libxcb-keysyms,
  libxcb-util,
  libxcb-wm,
  libxcursor,
  libxft,
  libxrandr,
  libxt,
  nix-update,
  pkg-config,
  writeShellScript,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spectrwm";
  version = "3.7.0";

  src = fetchFromGitHub {
    owner = "conformal";
    repo = "spectrwm";
    tag = "SPECTRWM_${lib.replaceStrings [ "." ] [ "_" ] finalAttrs.version}";
    hash = "sha256-wuBF+gCoqg5xIcb42rygS+lglghWqoNe0uAzyhe76eI=";
  };

  nativeBuildInputs = [ pkg-config ];

  buildInputs = [
    libxrandr
    libxcursor
    libxft
    libxt
    libxcb-util
    libxcb-keysyms
    libxcb-wm
    libbsd
  ];

  makeFlags = [ "PREFIX=${placeholder "out"}" ];
  sourceRoot = finalAttrs.src.name + (if stdenv.hostPlatform.isDarwin then "/osx" else "/linux");

  passthru.updateScript = writeShellScript "update-spectrwm" ''
    latestVersion=$(${lib.getExe curl} ''${GITHUB_TOKEN:+-u ":$GITHUB_TOKEN"} --silent --fail --location https://api.github.com/repos/conformal/spectrwm/releases/latest | ${lib.getExe jq} --raw-output .tag_name | grep -oP '\d+' | paste -sd.)
    ${lib.getExe nix-update} spectrwm --version=$latestVersion
  '';

  meta = {
    description = "Tiling window manager";

    longDescription = ''
      spectrwm is a small dynamic tiling window manager for X11. It
      tries to stay out of the way so that valuable screen real estate
      can be used for much more important stuff. It has sane defaults
      and does not require one to learn a language to do any
      configuration. It was written by hackers for hackers and it
      strives to be small, compact and fast.
    '';

    homepage = "https://github.com/conformal/spectrwm";
    license = lib.licenses.isc;

    maintainers = with lib.maintainers; [
      rake5k
    ];

    platforms = lib.platforms.all;
  };

})
