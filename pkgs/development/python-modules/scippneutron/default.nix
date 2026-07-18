{
  lib,
  fetchFromGitHub,
  anywidget,
  buildPythonPackage,
  cacert,
  curl,
  # dependencies
  email-validator,
  h5py,
  hypothesis,
  ipykernel,
  ipympl,
  lazy-loader,
  mpltoolbox,
  numpy,
  plopp,
  pooch,
  psutil,
  pydantic,
  pytest-xdist,
  # tests
  pytestCheckHook,
  python-dateutil,
  pythreejs,
  sciline,
  scipp,
  scippnexus,
  scipy,
  # build-system
  setuptools,
  setuptools-scm,
  stdenvNoCC,
}:

buildPythonPackage (finalAttrs: {
  pname = "scippneutron";
  version = "26.7.0";

  src = fetchFromGitHub {
    owner = "scipp";
    repo = "scippneutron";
    tag = finalAttrs.version;
    hash = "sha256-a/d2TLqrCgUknZ6wIPQRvL/X6v96ZBuL1HjChASeci8=";
  };

  env = {
    # See: https://github.com/scipp/scippneutron/blob/26.7.0/src/scippneutron/data/__init__.py
    SCIPPNEUTRON_DATA_DIR =
      let
        # NOTE this might be changed by upstream in the future.
        _version = "5";
      in
      stdenvNoCC.mkDerivation {
        strictDeps = true;

        nativeBuildInputs = [
          curl
        ];

        buildPhase =
          lib.pipe
            [
              "iris26176_graphite002_sqw.nxs"
              "loki-at-larmor.hdf5"
              "loki-at-larmor-filtered.hdf5"
              "powder-event.h5"
              "powder-event-filtered.h5"
              "mcstas_sans.h5"
              "CNCS_51936_event.nxs"
              "GEM40979.raw"
              "PG3_4844_calibration.h5"
              "PG3_4844_event.nxs"
              "PG3_4866_event.nxs"
              "PG3_4871_event.nxs"
              "WISH00016748.raw"
              "horace_sqw_4d.sqw"
              "dream_geant4_data.h5"
            ]
            [
              (map (
                f:
                "curl \"https://public.esss.dk/groups/scipp/scippneutron/${_version}/${f}\" --output \"$out/${_version}/${f}\""
              ))
              (lib.concatStringsSep "\n")
            ];

        __structuredAttrs = true;

        configurePhase = ''
          curlVersion=$(curl -V | head -1 | cut -d' ' -f2)
          curl=(
              curl
              --location
              --max-redirs 20
              --retry 3
              --retry-all-errors
              --continue-at -
              --disable-epsv
              --cookie-jar cookies
              --user-agent "curl/$curlVersion Nixpkgs"
          )
          export SSL_CERT_FILE="${cacert}/etc/ssl/certs/ca-bundle.crt"
          mkdir -p $out/${_version}
        '';

        dontFixup = true;
        dontInstall = true;
        dontUnpack = true;
        name = "plopp-test-data";
        outputHash = "sha256-UxFphegP2VdQ7zMssAf8FQbrQqOr4+qVjcIugxz0ZxA=";
        outputHashMode = "recursive";
      };
  };

  nativeCheckInputs = [
    pytestCheckHook
    anywidget
    hypothesis
    ipykernel
    ipympl
    pooch
    psutil
    pytest-xdist
    pythreejs
    sciline
  ];

  # See <https://github.com/scipp/scippneutron/issues/710>. From some reason
  # the whole file has to be deleted, otherwise the tests are not disabled.
  preCheck = ''
    rm tests/masking_tool_test.py
  '';

  __structuredAttrs = true;

  build-system = [
    setuptools
    setuptools-scm
  ];

  dependencies = [
    email-validator
    h5py
    lazy-loader
    mpltoolbox
    numpy
    plopp
    pydantic
    python-dateutil
    scipp
    scippnexus
    scipy
  ];

  pyproject = true;

  pythonImportsCheck = [
    "scippneutron"
  ];

  meta = {
    description = "Neutron scattering toolkit built using scipp for Data Reduction. Not facility or instrument specific";
    homepage = "https://scipp.github.io/scippneutron";
    changelog = "https://github.com/scipp/scippneutron/releases/tag/${finalAttrs.src.tag}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ doronbehar ];
  };
})
