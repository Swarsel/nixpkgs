{
  lib,
  fetchurl,
  buildPythonPackage,
  buildbot-pkg,
  cairosvg,
  jinja2,
  klein,
  mock,
  setuptools,
}:
{
  # this is exposed for potential plugins to use and for nix-update
  inherit buildbot-pkg;

  badges = buildPythonPackage rec {
    inherit (buildbot-pkg) version;
    pname = "buildbot_badges";

    src = fetchurl {
      url = "https://github.com/buildbot/buildbot/releases/download/v${version}/${pname}-${version}.tar.gz";
      hash = "sha256-u7HF6X+ClT4rT3LJcTHXWi5oSxCKPXoUDH+QFRI2S0w=";
    };

    # No tests
    doCheck = false;
    build-system = [ setuptools ];

    dependencies = [
      buildbot-pkg
      cairosvg
      klein
      jinja2
    ];

    pyproject = true;

    meta = {
      description = "Buildbot Badges Plugin";
      homepage = "https://buildbot.net/";
      license = lib.licenses.gpl2;
      maintainers = [ lib.maintainers.julienmalka ];
      teams = [ lib.teams.buildbot ];
    };
  };

  console-view = buildPythonPackage rec {
    inherit (buildbot-pkg) version;
    pname = "buildbot_console_view";

    src = fetchurl {
      url = "https://github.com/buildbot/buildbot/releases/download/v${version}/${pname}-${version}.tar.gz";
      hash = "sha256-VA6xqJBjD4XmQabTN8M+PLvfrG7Hq2ooxChtz2jAT8A=";
    };

    # No tests
    doCheck = false;
    build-system = [ setuptools ];
    dependencies = [ buildbot-pkg ];
    pyproject = true;

    meta = {
      description = "Buildbot Console View Plugin";
      homepage = "https://buildbot.net/";
      license = lib.licenses.gpl2;
      teams = [ lib.teams.buildbot ];
    };
  };

  grid-view = buildPythonPackage rec {
    inherit (buildbot-pkg) version;
    pname = "buildbot_grid_view";

    src = fetchurl {
      url = "https://github.com/buildbot/buildbot/releases/download/v${version}/${pname}-${version}.tar.gz";
      hash = "sha256-AmY8RkFX0POmVpW71nNz4+dFbr0FHGhNR3RJymDNoaw=";
    };

    # No tests
    doCheck = false;
    build-system = [ setuptools ];
    dependencies = [ buildbot-pkg ];
    pyproject = true;

    meta = {
      description = "Buildbot Grid View Plugin";
      homepage = "https://buildbot.net/";
      license = lib.licenses.gpl2;
      teams = [ lib.teams.buildbot ];
    };
  };

  waterfall-view = buildPythonPackage rec {
    inherit (buildbot-pkg) version;
    pname = "buildbot_waterfall_view";

    src = fetchurl {
      url = "https://github.com/buildbot/buildbot/releases/download/v${version}/${pname}-${version}.tar.gz";
      hash = "sha256-c/Nmr0Uscalnndq72Y6jPM1JDs5OyOCERtuX/GXkxp8=";
    };

    # No tests
    doCheck = false;
    build-system = [ setuptools ];
    dependencies = [ buildbot-pkg ];
    pyproject = true;

    meta = {
      description = "Buildbot Waterfall View Plugin";
      homepage = "https://buildbot.net/";
      license = lib.licenses.gpl2;
      teams = [ lib.teams.buildbot ];
    };
  };

  wsgi-dashboards = buildPythonPackage rec {
    inherit (buildbot-pkg) version;
    pname = "buildbot_wsgi_dashboards";

    src = fetchurl {
      url = "https://github.com/buildbot/buildbot/releases/download/v${version}/${pname}-${version}.tar.gz";
      hash = "sha256-vofKxpIfbAs7HR43Y7ojHLQEn6/WIdjZPgZieBMsz74=";
    };

    # No tests
    doCheck = false;
    build-system = [ setuptools ];
    dependencies = [ buildbot-pkg ];
    pyproject = true;

    meta = {
      description = "Buildbot WSGI dashboards Plugin";
      homepage = "https://buildbot.net/";
      license = lib.licenses.gpl2;
      teams = [ lib.teams.buildbot ];
    };
  };

  www = buildPythonPackage rec {
    inherit (buildbot-pkg) version;
    pname = "buildbot_www";

    src = fetchurl {
      url = "https://github.com/buildbot/buildbot/releases/download/v${version}/${pname}-${version}.tar.gz";
      hash = "sha256-mn55+Fb2cU2rNB5Nwt41nWXjcZfgd07ijYAAnZnnnwI=";
    };

    # Remove unnecessary circular dependency on buildbot
    postPatch = ''
      sed -i "s/'buildbot'//" setup.py
    '';

    # No tests
    doCheck = false;
    build-system = [ setuptools ];

    dependencies = [
      buildbot-pkg
      mock
    ];

    pyproject = true;

    meta = {
      description = "Buildbot UI";
      homepage = "https://buildbot.net/";
      license = lib.licenses.gpl2;
      teams = [ lib.teams.buildbot ];
    };
  };
}
