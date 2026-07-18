{
  lib,
  fetchFromGitHub,
  bash,
  fetchPypi,
  python3,
}:

let
  python = python3.override {
    packageOverrides = self: super: {
      certbot = super.certbot.overridePythonAttrs rec {
        version = "3.1.0";

        src = fetchFromGitHub {
          owner = "certbot";
          repo = "certbot";
          tag = "v${version}";
          hash = "sha256-lYGJgUNDzX+bE64GJ+djdKR+DXmhpcNbFJrAEnP86yQ=";
        };
      };

      josepy = super.josepy.overridePythonAttrs (old: rec {
        version = "1.15.0";

        src = fetchFromGitHub {
          owner = "certbot";
          repo = "josepy";
          tag = "v${version}";
          hash = "sha256-fK4JHDP9eKZf2WO+CqRdEjGwJg/WNLvoxiVrb5xQxRc=";
        };

        dependencies = with self; [
          pyopenssl
          cryptography
        ];
      });
    };

    self = python;
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "simp_le-client";
  version = "0.20.0";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-p6+OF8MuAzcdTV4/CvZpjGaOrg7xcNuEddk7yC2sXIE=";
  };

  postPatch = ''
    # drop upper bound of idna requirement
    sed -ri "s/'(idna)<[^']+'/'\1'/" setup.py
    substituteInPlace simp_le.py \
      --replace "/bin/sh" "${bash}/bin/sh"
  '';

  checkPhase = ''
    runHook preCheck
    $out/bin/simp_le --test
    runHook postCheck
  '';

  # both setuptools-scm and mock are runtime dependencies
  dependencies = with python.pkgs; [
    acme
    cryptography
    setuptools-scm
    josepy
    idna
    mock
    pyopenssl
    pytz
    six
  ];

  pyproject = true;

  pythonRelaxDeps = [
    "acme"
  ];

  meta = {
    description = "Simple Let's Encrypt client";
    homepage = "https://github.com/zenhack/simp_le";
    license = lib.licenses.gpl3;

    maintainers = with lib.maintainers; [
      makefu
    ];

    platforms = lib.platforms.linux;
  };
}
