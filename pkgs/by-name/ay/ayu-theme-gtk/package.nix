{
  lib,
  stdenv,
  fetchFromGitHub,
  autoreconfHook,
  gnome-shell,
  gnome-themes-extra,
  gtk-engine-murrine,
  gtk3,
  inkscape,
  optipng,
  pkg-config,
  sassc,
}:

stdenv.mkDerivation rec {
  pname = "ayu-theme-gtk";
  version = "unstable-2017-05-12";

  src = fetchFromGitHub {
    owner = "dnordstrom";
    repo = "ayu-theme";
    rev = "cc6f3d3b72897c304e2f00afcaf51df863155e35";
    sha256 = "sha256-1EhTfPhYl+4IootTCCE04y6V7nW1/eWdHarfF7/j1U0=";
  };

  postPatch = ''
    ln -sn 3.20 common/gtk-3.0/3.24
    ln -sn 3.18 common/gnome-shell/3.24
  '';

  nativeBuildInputs = [
    autoreconfHook
    gtk3
    inkscape
    optipng
    pkg-config
    sassc
  ];

  configureFlags = [
    "--with-gnome-shell=${gnome-shell.version}"
    "--disable-unity"
  ];

  preBuild = ''
    # Shut up inkscape's warnings about creating profile directory
    export HOME="$NIX_BUILD_ROOT"
  '';

  postInstall = ''
    install -Dm644 -t $out/share/doc/${pname} AUTHORS *.md
  '';

  enableParallelBuilding = true;

  propagatedUserEnvPkgs = [
    gnome-themes-extra
    gtk-engine-murrine
  ];

  meta = {
    description = "Ayu colored GTK and Kvantum themes based on Arc";
    homepage = "https://github.com/dnordstrom/ayu-theme/";
    license = lib.licenses.gpl3;
    maintainers = with lib.maintainers; [ lovesegfault ];
    platforms = lib.platforms.linux;
  };
}
