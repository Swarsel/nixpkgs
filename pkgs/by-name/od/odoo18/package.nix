{
  lib,
  fetchzip,
  nixosTests,
  python312,
  rtlcss,
  wkhtmltopdf,
}:

let
  odoo_version = "18.0";
  odoo_release = "20260420";
  python = python312.override {
    self = python;
  };
in
python.pkgs.buildPythonApplication rec {
  pname = "odoo";
  version = "${odoo_version}.${odoo_release}";

  src = fetchzip {
    # find latest version on https://nightly.odoo.com/${odoo_version}/nightly/src
    url = "https://nightly.odoo.com/${odoo_version}/nightly/src/odoo_${version}.tar.gz";
    hash = "sha256-+ilM07s33pdwZc3XoAXbID7MRz/m6PHnzjHzi183eyM="; # odoo
    name = "odoo-${version}";
  };

  postPatch = ''
    # hardcode the location of the unwrapped python scrip, otherwise the websocket
    # server (called longpoll in codebase) will fail to start.
    substituteInPlace odoo/service/server.py \
      --replace-fail 'sys.argv[0]' "'${placeholder "out"}/bin/.odoo-wrapped'"
  '';

  build-system = with python.pkgs; [
    setuptools
    distutils
  ];

  dependencies = with python.pkgs; [
    asn1crypto
    babel
    cbor2
    chardet
    cryptography
    decorator
    docutils
    ebaysdk
    freezegun
    geoip2
    gevent
    greenlet
    idna
    jinja2
    libsass
    lxml
    lxml-html-clean
    markupsafe
    num2words
    ofxparse
    openpyxl
    passlib
    pillow
    polib
    psutil
    psycopg2
    pydot
    pyopenssl
    pypdf
    pyserial
    python-dateutil
    python-ldap
    python-stdnum
    pytz
    pyusb
    qrcode
    reportlab
    requests
    rjsmin
    urllib3
    vobject
    werkzeug
    xlrd
    xlsxwriter
    xlwt
    zeep
  ];

  # takes 5+ minutes and there are not files to strip
  dontStrip = true;

  makeWrapperArgs = [
    "--prefix PATH : ${
      lib.makeBinPath [
        wkhtmltopdf
        rtlcss
      ]
    }"
  ];

  pyproject = true;
  pythonRemoveDeps = [ "PyPDF2" ];

  passthru = {
    tests = {
      inherit (nixosTests) odoo18 odoo18-multiprocess;
    };

    updateScript = ./update.sh;
  };

  meta = {
    description = "Open Source ERP and CRM";
    homepage = "https://www.odoo.com/";
    license = lib.licenses.lgpl3Only;

    maintainers = with lib.maintainers; [
      mkg20001
      siriobalmelli
    ];
  };
}
