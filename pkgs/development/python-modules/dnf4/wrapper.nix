{
  lib,
  stdenv,
  dnf-plugins-core,
  dnf4,
  python,
  wrapPython,
  plugins ? [ dnf-plugins-core ],
}:
let
  pluginPaths = map (p: "${p}/${python.sitePackages}/dnf-plugins") plugins;

  dnf4-unwrapped = dnf4;
in

stdenv.mkDerivation {
  inherit (dnf4-unwrapped) version;
  pname = "dnf4";

  outputs = [
    "out"
    "man"
    "py"
  ];

  nativeBuildInputs = [ wrapPython ];
  propagatedBuildInputs = [ dnf4-unwrapped ] ++ plugins;

  installPhase = ''
    runHook preInstall

    cp -R ${dnf4-unwrapped} $out
    cp -R ${dnf4-unwrapped.py} $py
    cp -R ${dnf4-unwrapped.man} $man

    runHook postInstall
  '';

  postFixup = ''
    wrapPythonPrograms
  '';

  dontUnpack = true;

  makeWrapperArgs = lib.optional (
    plugins != [ ]
  ) ''--add-flags "--setopt=pluginpath=${lib.concatStringsSep "," pluginPaths}"'';

  passthru = {
    unwrapped = dnf4-unwrapped;
  };

  meta = dnf4-unwrapped.meta // {
    priority = (dnf4-unwrapped.meta.priority or lib.meta.defaultPriority) - 1;
  };
}
