{ lib, stdenv, fetchFromGitHub, makeWrapper, cmake, ninja, pkg-config, m4, perl, bash
, xdg-utils, zip, unzip, gzip, bzip2, gnutar, p7zip, xz
, IOKit, Carbon, Cocoa, AudioToolbox, OpenGL, System
, withTTYX ? true, libX11
, withGUI ? true, wxGTK32
, withUCD ? true, libuchardet

# Plugins
, withColorer ? true, spdlog, xercesc
, withMultiArc ? true, libarchive, pcre
, withNetRocks ? true, openssl, libssh, samba, libnfs, neon
, withPython ? false, python3Packages
}:

stdenv.mkDerivation rec {
  pname = "far2l";
  version = "2.6.0";

  src = fetchFromGitHub {
    owner = "elfmz";
    repo = "far2l";
    rev = "v_${version}";
    sha256 = "sha256-fLBWHhvfqEiaZkFyNs8CKr5vFMQ5mrbo/X3oGwJmFoo=";
  };

  nativeBuildInputs = [ cmake ninja pkg-config m4 perl makeWrapper ];

  buildInputs = lib.optional withTTYX libX11
    ++ lib.optional withGUI wxGTK32
    ++ lib.optional withUCD libuchardet
    ++ lib.optionals withColorer [ spdlog xercesc ]
    ++ lib.optionals withMultiArc [ libarchive pcre ]
    ++ lib.optionals withNetRocks [ openssl libssh libnfs neon ]
    ++ lib.optional (withNetRocks && !stdenv.isDarwin) samba # broken on darwin
    ++ lib.optionals withPython (with python3Packages; [ python cffi debugpy pcpp ])
    ++ lib.optionals stdenv.isDarwin [ IOKit Carbon Cocoa AudioToolbox OpenGL System ];

  postPatch = ''
    patchShebangs python/src/prebuild.sh
    patchShebangs far2l/bootstrap/view.sh
  '';

  cmakeFlags = [
    (lib.cmakeBool "TTYX" withTTYX)
    (lib.cmakeBool "USEWX" withGUI)
    (lib.cmakeBool "USEUCD" withUCD)
    (lib.cmakeBool "COLORER" withColorer)
    (lib.cmakeBool "MULTIARC" withMultiArc)
    (lib.cmakeBool "NETROCKS" withNetRocks)
    (lib.cmakeBool "PYTHON" withPython)
  ] ++ lib.optionals withPython [
    (lib.cmakeFeature "VIRTUAL_PYTHON" "python")
    (lib.cmakeFeature "VIRTUAL_PYTHON_VERSION" "python")
  ];

  runtimeDeps = [ unzip zip p7zip xz gzip bzip2 gnutar ];

  postInstall = ''
    wrapProgram $out/bin/far2l \
      --argv0 $out/bin/far2l \
      --prefix PATH : ${lib.makeBinPath runtimeDeps} \
      --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  meta = with lib; {
    description = "Linux port of FAR Manager v2, a program for managing files and archives in Windows operating systems";
    homepage = "https://github.com/elfmz/far2l";
    license = licenses.gpl2Only;
    maintainers = with maintainers; [ hypersw ];
    platforms = platforms.unix;
  };
}
