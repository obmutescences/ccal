{ lib, stdenv, makeWrapper, ghostscript_headless, src }:

stdenv.mkDerivation {
  pname = "ccal";
  version = "2.5.3";
  inherit src;

  nativeBuildInputs = [ makeWrapper ];

  # Upstream 2.5.3 builds the in-tree NOVAS sources as C++.
  # The later fork's Makefile references ../novas3 (outside the repo) and
  # needs those sources compiled as C because ccal.cpp uses extern "C".
  postPatch = ''
    if grep -q '\.\./novas3' Makefile; then
      sed -i -e 's|\.\./novas3/||g' -e '/readeph0/d' Makefile
      sed -i '/-I\.\.\/novas3/d' Makefile
      sed -i 's|^CXXFLAGS += -DUSE_YEARCACHE|# &|' Makefile
      cat >> Makefile <<'EOF'
novas.o: novas.cpp
	$(CC) -x c -std=gnu99 $(CFLAGS) -c -o $@ $<
novascon.o: novascon.cpp
	$(CC) -x c -std=gnu99 $(CFLAGS) -c -o $@ $<
nutation.o: nutation.cpp
	$(CC) -x c -std=gnu99 $(CFLAGS) -c -o $@ $<
solsys3.o: solsys3.cpp
	$(CC) -x c -std=gnu99 $(CFLAGS) -c -o $@ $<
EOF
    fi
  '';

  makeFlags = [
    "CXX:=$(CXX)"
    "BINDIR=$(out)/bin"
    "MANDIR=$(out)/share/man"
  ];

  installTargets = [ "install" "install-man" ];

  # ccalpdf depends on a `ps2pdf` binary in PATH
  postFixup = ''
    wrapProgram $out/bin/ccalpdf \
      --prefix PATH : ${lib.makeBinPath [ ghostscript_headless ]}:$out/bin
  '';

  meta = {
    homepage = "https://github.com/obmutescences/ccal";
    description = "Command line Chinese calendar viewer, similar to cal";
    license = lib.licenses.gpl2Plus;
    mainProgram = "ccal";
    platforms = lib.platforms.all;
  };
}
