Name: boost
Summary: The Boost C++ Libraries
Version: 1.45.0
Release: 0%{?dist}
License: Boost
URL: http://www.boost.org/
Group: System Environment/Libraries
Source: boost_1_45_0.tar.gz
Obsoletes: boost-doc < 1.45.0
Obsoletes: boost-python < 1.45.0
Provides: boost-doc = %{version}-%{release}

# boost is an "umbrella" package that pulls in all other boost components
Requires: boost-date-time = %{version}-%{release}
Requires: boost-filesystem = %{version}-%{release}
Requires: boost-graph = %{version}-%{release}
Requires: boost-iostreams = %{version}-%{release}
Requires: boost-math = %{version}-%{release}
Requires: boost-random = %{version}-%{release}
Requires: boost-test = %{version}-%{release}
Requires: boost-program-options = %{version}-%{release}
Requires: boost-python = %{version}-%{release}
Requires: boost-regex = %{version}-%{release}
Requires: boost-serialization = %{version}-%{release}
Requires: boost-signals = %{version}-%{release}
Requires: boost-system = %{version}-%{release}
Requires: boost-thread = %{version}-%{release}
Requires: boost-wave = %{version}-%{release}


BuildRoot: %{_tmppath}/%{name}-%{version}-%{release}-root-%(%{__id_u} -n)
BuildRequires: libstdc++-devel
BuildRequires: bzip2-libs
BuildRequires: bzip2-devel
BuildRequires: zlib-devel
BuildRequires: python-devel
BuildRequires: libicu-devel
BuildRequires: chrpath
#Patch0: boost-version-override.patch
#Patch1: boost-use-rpm-optflags.patch
#Patch2: boost-run-tests.patch
#Patch3: boost-soname.patch
#Patch4: boost-unneccessary_iostreams.patch
#Patch5: boost-bitset.patch
#Patch6: boost-function_template.patch
#Patch7: boost-fs_gcc44.patch
#Patch8: boost-openssl-1.0.patch
#Patch9: boost-gil_gcc44.patch
#Patch10: boost-python_call_operator.patch
#Patch11: boost-python_enums.patch
#Patch12: boost-python_uint.patch
#Patch13: boost-python_translate_exception.patch

%bcond_with tests
%bcond_with docs_generated
%define sonamever 5

%description
Boost provides free peer-reviewed portable C++ source libraries.  The
emphasis is on libraries which work well with the C++ Standard
Library, in the hopes of establishing "existing practice" for
extensions and providing reference implementations so that the Boost
libraries are suitable for eventual standardization. (Some of the
libraries have already been proposed for inclusion in the C++
Standards Committee\'s upcoming C++ Standard Library Technical Report.)

%package date-time
Summary: Runtime component of boost date-time library
Group: System Environment/Libraries

%description date-time

Runtime support for Boost Date Time, set of date-time libraries based
on generic programming concepts.

%package filesystem
Summary: Runtime component of boost filesystem library
Group: System Environment/Libraries

%description filesystem

Runtime support for the Boost Filesystem Library, which provides
portable facilities to query and manipulate paths, files, and
directories.

%package graph
Summary: Runtime component of boost graph library
Group: System Environment/Libraries

%description graph

Runtime support for the BGL graph library.  BGL interface and graph
components are generic, in the same sense as the the Standard Template
Library (STL).

%package iostreams
Summary: Runtime component of boost iostreams library
Group: System Environment/Libraries

%description iostreams

Runtime support for Boost.IOStreams, a framework for defining streams,
stream buffers and i/o filters.

%package math
Summary: Runtime component of boost math library
Group: System Environment/Libraries

%description math

Runtime support Boost.Math, a library of math and numeric tools.

%package random
Summary: Runtime component of boost random library
Group: System Environment/Libraries

%description random

Runtime support Boost.Random, a library of random tools.

%package test
Summary: Runtime component of boost test library
Group: System Environment/Libraries

%description test

Runtime support for simple program testing, full unit testing, and for
program execution monitoring.

%package program-options
Summary:  Runtime component of boost program_options library
Group: System Environment/Libraries

%description program-options

Runtime support of boost program options library, which allows program
developers to obtain (name, value) pairs from the user, via
conventional methods such as command line and config file.

%package python
Summary: Runtime component of boost python library
Group: System Environment/Libraries

%description python

The Boost Python Library is a framework for interfacing Python and
C++. It allows you to quickly and seamlessly expose C++ classes
functions and objects to Python, and vice-versa, using no special
tools -- just your C++ compiler.  This package contains runtime
support for Boost Python Library.

%package regex
Summary: Runtime component of boost regular expression library
Group: System Environment/Libraries

%description regex

Runtime support for boost regular expression library.

%package serialization
Summary: Runtime component of boost serialization library
Group: System Environment/Libraries

%description serialization

Runtime support for serialization for persistence and marshalling.

%package signals
Summary: Runtime component of boost signals and slots library
Group: System Environment/Libraries

%description signals

Runtime support for managed signals & slots callback implementation.

%package system
Summary: Runtime component of boost system support library
Group: System Environment/Libraries

%description system

Runtime component of Boost operating system support library, including
the diagnostics support that will be part of the C++0x standard
library.

%package wave
Summary: Runtime component of boost C99/C++ preprocessing library
Group: System Environment/Libraries

%description wave

Runtime support for the Boost.Wave library, a Standards conformant,
and highly configurable implementation of the mandated C99/C++
preprocessor functionality.

%package thread
Summary: Runtime component of boost thread library
Group: System Environment/Libraries

%description thread

Runtime component Boost.Thread library, which provides classes and
functions for managing multiple threads of execution, and for
synchronizing data between the threads or providing separate copies of
data specific to individual threads.

%package devel
Summary: The Boost C++ headers and shared development libraries
Group: Development/Libraries
Requires: boost = %{version}-%{release}
Provides: boost-python-devel = %{version}-%{release}

%description devel
Headers and shared object symlinks for the Boost C++ libraries.

%package static
Summary: The Boost C++ static development libraries
Group: Development/Libraries
Requires: boost-devel = %{version}-%{release}
Obsoletes: boost-devel-static < 1.45.0
Provides: boost-devel-static = %{version}-%{release}

%description static
Static Boost C++ libraries.

%package doc
Summary: The Boost C++ html docs
Group: Documentation
Provides: boost-python-docs = %{version}-%{release}

%description doc
HTML documentation files for Boost C++ libraries.

%prep
%setup -q -n %{name}_1_45_0
#%patch0 -p0
#sed 's/_FEDORA_OPT_FLAGS/%{optflags}/' %{PATCH1} | %{__patch} -p0 --fuzz=0
#%patch2 -p0
#sed 's/_FEDORA_SONAME/%{sonamever}/' %{PATCH3} | %{__patch} -p0 --fuzz=0
#%patch4 -p0
#%patch5 -p0
#%patch6 -p0
#%patch7 -p0
#%patch8 -p1
#%patch9 -p0
#%patch10 -p2
#%patch11 -p2
#%patch12 -p2
#%patch13 -p1

%build
BOOST_ROOT=`pwd`
export BOOST_ROOT

# build make tools, ie bjam, necessary for building libs, docs, and testing
(cd tools/build/v2/engine/src && ./build.sh)
BJAM=`find tools/build/v2/engine/src/ -name bjam -a -type f`

CONFIGURE_FLAGS="--with-toolset=gcc"
PYTHON_VERSION=$(python -c 'import sys; print sys.version[:3]')
PYTHON_FLAGS="--with-python-root=/usr --with-python-version=$PYTHON_VERSION"
REGEX_FLAGS="--with-icu"
./bootstrap.sh $CONFIGURE_FLAGS $PYTHON_FLAGS $REGEX_FLAGS 

BUILD_VARIANTS="variant=release threading=multi debug-symbols=on"
BUILD_FLAGS="-d2 --layout=system $BUILD_VARIANTS"
$BJAM $BUILD_FLAGS %{?_smp_mflags} stage 

# build docs, requires a network connection for docbook XSLT stylesheets
%if %{with docs_generated}
cd ./doc
chmod +x ../tools/boostbook/setup_boostbook.sh
../tools/boostbook/setup_boostbook.sh
USER_CFG=$BOOST_ROOT/tools/build/v2/user-config.jam
$BOOST_ROOT/$BJAM --v2 -sICU_PATH=/usr --user-config=$USER_CFG html
cd ..
%endif

%check
%if %{with tests}
echo "<p>" `uname -a` "</p>" > status/regression_comment.html
echo "" >> status/regression_comment.html
echo "<p>" `g++ --version` "</p>" >> status/regression_comment.html
echo "" >> status/regression_comment.html

cd tools/regression/build
#$BOOST_ROOT/$BJAM
cd ../test
#python ./test.py
cd ../../..

results1=status/cs-`uname`.html
results2=status/cs-`uname`-links.html
email=thibault@mc2.io
if [ -f $results1 ] && [ -f $results2 ]; then
  echo "sending results starting"
  testdate=`date +%Y%m%d`
  testarch=`uname -m`
  results=boost-results-$testdate-$testarch.tar.bz2
  tar -cvf boost-results-$testdate-$testarch.tar $results1 $results2
  bzip2 -f boost-results-$testdate-$testarch.tar 
  echo | mutt -s "$testdate boost regression $testarch" -a $results $email 
  echo "sending results finished"
else
  echo "error sending results"
fi
%endif

%install
rm -rf $RPM_BUILD_ROOT
mkdir -p $RPM_BUILD_ROOT%{_libdir}
#mkdir -p $RPM_BUILD_ROOT%{_staticlibdir}
mkdir -p $RPM_BUILD_ROOT%{_includedir}
mkdir -p $RPM_BUILD_ROOT%{_docdir}/%{name}-%{version}

# install lib
for i in `find stage -type f -name \*.a`; do
  NAME=`basename $i`;
  install -p -m 0644 $i $RPM_BUILD_ROOT%{_libdir}/$NAME;
#  install -p -m 0644 $i $RPM_BUILD_ROOT%{_staticlibdir}/$NAME;
done;
echo `pwd`
for i in `find stage -name \*.so`; do
  echo "DEBUG"
  echo i
  NAME=$i;
  SONAME=$i.%{sonamever};
  VNAME=$i.%{version};
  base=`basename $i`;
  NAMEbase=$base;
  SONAMEbase=$base.%{sonamever};
  VNAMEbase=$base.%{version};
  (mv $i $VNAME) || echo "file exists";

  # remove rpath
  chrpath --delete $VNAME;

  ln -s $VNAMEbase $SONAME;
  (ln -s $VNAMEbase $NAME) || echo "file exists";
  install -p -m 755 $VNAME $RPM_BUILD_ROOT%{_libdir}/$VNAMEbase; 

  mv $SONAME $RPM_BUILD_ROOT%{_libdir}/$SONAMEbase;
  mv $NAME $RPM_BUILD_ROOT%{_libdir}/$NAMEbase;
done;

# install include files
find %{name} -type d | while read a; do
  mkdir -p $RPM_BUILD_ROOT%{_includedir}/$a
  find $a -mindepth 1 -maxdepth 1 -type f \
  | xargs -r install -m 644 -p -t $RPM_BUILD_ROOT%{_includedir}/$a
done

# install doc files
DOCPATH=$RPM_BUILD_ROOT%{_docdir}/%{name}-%{version}/
find libs doc more -type f \( -name \*.htm -o -name \*.html \) \
    | sed -n '/\//{s,/[^/]*$,,;p}' \
    | sort -u > tmp-doc-directories
sed "s:^:$DOCPATH:" tmp-doc-directories | xargs -r mkdir -p
cat tmp-doc-directories | while read a; do
    find $a -mindepth 1 -maxdepth 1 -name \*.htm\* \
    | xargs install -m 644 -p -t $DOCPATH$a
done
rm tmp-doc-directories
install -p -m 644 -t $DOCPATH LICENSE_1_0.txt index.htm index.html

# remove scripts used to generate include files
find $RPM_BUILD_ROOT%{_includedir}/ \( -name '*.pl' -o -name '*.sh' \) -exec rm {} \;

%clean
rm -rf $RPM_BUILD_ROOT

%post -p /sbin/ldconfig

%postun -p /sbin/ldconfig

%files

%files date-time
%defattr(-, root, root, -)
%{_libdir}/libboost_date_time*.so.%{version}
%{_libdir}/libboost_date_time*.so.%{sonamever}

%files filesystem
%defattr(-, root, root, -)
%{_libdir}/libboost_filesystem*.so.%{version}
%{_libdir}/libboost_filesystem*.so.%{sonamever}

%files graph
%defattr(-, root, root, -)
%{_libdir}/libboost_graph*.so.%{version}
%{_libdir}/libboost_graph*.so.%{sonamever}

%files iostreams
%defattr(-, root, root, -)
%{_libdir}/libboost_iostreams*.so.%{version}
%{_libdir}/libboost_iostreams*.so.%{sonamever}

%files math
%defattr(-, root, root, -)
%{_libdir}/libboost_math*.so.%{version}
%{_libdir}/libboost_math*.so.%{sonamever}

%files test
%defattr(-, root, root, -)
%{_libdir}/libboost_prg_exec_monitor*.so.%{version}
%{_libdir}/libboost_prg_exec_monitor*.so.%{sonamever}
%{_libdir}/libboost_unit_test_framework*.so.%{version}
%{_libdir}/libboost_unit_test_framework*.so.%{sonamever}

%files program-options
%defattr(-, root, root, -)
%{_libdir}/libboost_program_options*.so.%{version}
%{_libdir}/libboost_program_options*.so.%{sonamever}

%files python
%defattr(-, root, root, -)
%{_libdir}/libboost_python*.so.%{version}
%{_libdir}/libboost_python*.so.%{sonamever}

%files random
%defattr(-, root, root, -)
%{_libdir}/libboost_random*.so.%{version}
%{_libdir}/libboost_random*.so.%{sonamever}

%files regex
%defattr(-, root, root, -)
%{_libdir}/libboost_regex*.so.%{version}
%{_libdir}/libboost_regex*.so.%{sonamever}

%files serialization
%defattr(-, root, root, -)
%{_libdir}/libboost_serialization*.so.%{version}
%{_libdir}/libboost_serialization*.so.%{sonamever}
%{_libdir}/libboost_wserialization*.so.%{version}
%{_libdir}/libboost_wserialization*.so.%{sonamever}

%files signals
%defattr(-, root, root, -)
%{_libdir}/libboost_signals*.so.%{version}
%{_libdir}/libboost_signals*.so.%{sonamever}

%files system
%defattr(-, root, root, -)
%{_libdir}/libboost_system*.so.%{version}
%{_libdir}/libboost_system*.so.%{sonamever}

%files thread
%defattr(-, root, root, -)
%{_libdir}/libboost_thread*.so.%{version}
%{_libdir}/libboost_thread*.so.%{sonamever}

%files wave
%defattr(-, root, root, -)
%{_libdir}/libboost_wave*.so.%{version}
%{_libdir}/libboost_wave*.so.%{sonamever}

%files doc
%defattr(-, root, root, -)
%doc %{_docdir}/%{name}-%{version}

%files devel
%defattr(-, root, root, -)
%{_includedir}/boost
%{_libdir}/*.so

%files static
%defattr(-, root, root, -)
%{_staticlibdir}/*.a

%changelog
* Tue Apr 02 2013 Thibault BRONCHAIN <thibault@mc2.io> - 1.45.0-0
- First creation
