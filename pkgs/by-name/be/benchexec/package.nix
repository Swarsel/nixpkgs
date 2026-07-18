{
  lib,
  fetchFromGitHub,
  benchexec,
  libseccomp,
  nixosTests,
  python3,
  testers,
}:
python3.pkgs.buildPythonApplication (finalAttrs: {
  pname = "benchexec";
  version = "3.27";

  src = fetchFromGitHub {
    owner = "sosy-lab";
    repo = "benchexec";
    tag = finalAttrs.version;
    hash = "sha256-lokz7klAQAascij0T/T43/PrbMh6ZUAvFnIqg13pVUk=";
  };

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'setuptools ==' 'setuptools >='
  '';

  nativeBuildInputs = with python3.pkgs; [ setuptools ];

  # NOTE: CPU Energy Meter is not added,
  # because BenchExec should call the wrapper configured
  # via `security.wrappers.cpu-energy-meter`
  # in `programs.cpu-energy-meter`, which will have the required
  # capabilities to access MSR.
  # If we add `cpu-energy-meter` here, BenchExec will instead call an executable
  # without `CAP_SYS_RAWIO` and fail.
  propagatedBuildInputs = with python3.pkgs; [
    coloredlogs
    lxml
    pystemd
    pyyaml
  ];

  makeWrapperArgs = [ "--set-default LIBSECCOMP ${lib.getLib libseccomp}/lib/libseccomp.so" ];
  pyproject = true;

  passthru.tests =
    let
      testVersion =
        result:
        testers.testVersion {
          command = "${result} --version";
          package = benchexec;
        };
    in
    {
      benchexec-version = testVersion "benchexec";
      containerexec-version = testVersion "containerexec";
      nixos = nixosTests.benchexec;
      runexec-version = testVersion "runexec";
      table-generator-version = testVersion "table-generator";
    };

  meta = {
    description = "Framework for Reliable Benchmarking and Resource Measurement";
    homepage = "https://github.com/sosy-lab/benchexec";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ lorenzleutgeb ];
    mainProgram = "benchexec";
  };
})
