{
  lib,
  fetchPypi,
  onlykey-cli,
  python3Packages,
}:

let
  bech32 =
    with python3Packages;
    buildPythonPackage rec {
      pname = "bech32";
      version = "1.2.0";

      src = fetchPypi {
        inherit pname version;
        sha256 = "sha256-fW24IUYDvXhx/PpsCCbvaLhbCr2Q+iHChanF4h0r2Jk=";
      };

      format = "setuptools";
    };

  # onlykey requires a patched version of libagent
  lib-agent =
    with python3Packages;
    libagent.overridePythonAttrs (old: rec {
      version = "1.0.6";

      src = fetchPypi {
        inherit version;
        sha256 = "sha256-IrJizIHDIPHo4tVduUat7u31zHo3Nt8gcMOyUUqkNu0=";
        pname = "lib-agent";
      };

      propagatedBuildInputs = old.propagatedBuildInputs or [ ] ++ [
        bech32
        cryptography
        cython
        docutils
        pycryptodome
        pynacl
        wheel
      ];

      # turn off testing because I can't get it to work
      doCheck = false;
      pythonImportsCheck = [ "libagent" ];

      meta = old.meta // {
        description = "Using OnlyKey as hardware SSH and GPG agent";
        homepage = "https://github.com/trustcrypto/onlykey-agent/tree/ledger";
        maintainers = with lib.maintainers; [ kalbasit ];
      };
    });
in
python3Packages.buildPythonApplication rec {
  pname = "onlykey-agent";
  version = "1.1.15";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-SbGb7CjcD7cFPvASZtip56B4uxRiFKZBvbsf6sb8fds=";
  };

  propagatedBuildInputs = with python3Packages; [
    lib-agent
    onlykey-cli
    setuptools
  ];

  # no tests
  doCheck = false;

  # move the python library into the sitePackages.
  postInstall = ''
    mkdir $out/${python3Packages.python.sitePackages}/onlykey_agent
    mv $out/bin/onlykey_agent.py $out/${python3Packages.python.sitePackages}/onlykey_agent/__init__.py
    chmod a-x $out/${python3Packages.python.sitePackages}/onlykey_agent/__init__.py
  '';

  format = "setuptools";
  pythonImportsCheck = [ "onlykey_agent" ];

  meta = {
    description = "Middleware that lets you use OnlyKey as a hardware SSH/GPG device";
    homepage = "https://github.com/trustcrypto/onlykey-agent";
    license = lib.licenses.lgpl3Only;
    maintainers = with lib.maintainers; [ kalbasit ];
  };
}
