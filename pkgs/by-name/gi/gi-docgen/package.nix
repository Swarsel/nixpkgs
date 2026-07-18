{
  lib,
  fetchurl,
  gnome,
  meson,
  ninja,
  python3,
  versionCheckHook,
}:

python3.pkgs.buildPythonApplication rec {
  pname = "gi-docgen";
  version = "2026.1";

  src = fetchurl {
    url = "mirror://gnome/sources/gi-docgen/${lib.versions.major version}/gi-docgen-${version}.tar.xz";
    hash = "sha256-wxbWwEaZl2toI5Eqrh+ypqP/olU7Qivoj7VuuIGs9Hk=";
  };

  nativeBuildInputs = [
    meson
    ninja
  ];

  # For Python this must be placed in nativeCheckInputs instead of nativeInstallCheckInputs
  # https://github.com/nixos/nixpkgs/issues/420531
  nativeCheckInputs = [ versionCheckHook ];

  postFixup = ''
    # Do not propagate Python
    substituteInPlace $out/nix-support/propagated-build-inputs \
      --replace-fail "${python3}" ""
  '';

  # doCheck = false; # no tests - restore this after versionCheckHook can be moved
  __structuredAttrs = true;

  depsBuildBuild = [
    python3
  ];

  pyproject = false;

  pythonPath = with python3.pkgs; [
    jinja2
    markdown
    markupsafe
    packaging
    pygments
    typogrify
  ];

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gi-docgen";
    };
  };

  meta = {
    description = "Documentation generator for GObject-based libraries";
    homepage = "https://gitlab.gnome.org/GNOME/gi-docgen";
    license = lib.licenses.asl20; # OR GPL-3.0-or-later
    mainProgram = "gi-docgen";
    teams = [ lib.teams.gnome ];
  };
}
