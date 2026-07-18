{
  ceph-meta,
  ceph-python,
  ceph-src,
}:

ceph-python.pkgs.buildPythonPackage {
  inherit (ceph-src) version;
  pname = "ceph-common";
  src = ceph-src;

  nativeCheckInputs = with ceph-python.pkgs; [
    pytestCheckHook
  ];

  build-system = with ceph-python.pkgs; [
    setuptools
  ];

  dependencies = with ceph-python.pkgs; [
    pyyaml
  ];

  disabledTests = [
    # requires network access
    "test_valid_addr"
  ];

  pyproject = true;
  sourceRoot = "${ceph-src.name}/src/python-common";
  meta = ceph-meta "Ceph common module for code shared by manager modules";
}
