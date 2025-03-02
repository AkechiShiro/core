#!/usr/bin/env bash

#
#	MetaCall Configuration Environment Bash Script by Parra Studios
#	Configure and install MetaCall environment script utility.
#
#	Copyright (C) 2016 - 2022 Vicente Eduardo Ferrer Garcia <vic798@gmail.com>
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#		http://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#

ROOT_DIR=$(pwd)

RUN_AS_ROOT=0
SUDO_CMD=sudo
APT_CACHE=0
APT_CACHE_CMD=""
INSTALL_APT=1
INSTALL_PYTHON=0
INSTALL_RUBY=0
INSTALL_RUST=0
INSTALL_RAPIDJSON=0
INSTALL_FUNCHOOK=0
INSTALL_NETCORE=0
INSTALL_NETCORE2=0
INSTALL_NETCORE5=0
INSTALL_V8=0
INSTALL_V8REPO=0
INSTALL_V8REPO58=0
INSTALL_V8REPO57=0
INSTALL_V8REPO54=0
INSTALL_V8REPO52=0
INSTALL_V8REPO51=0
INSTALL_NODEJS=0
INSTALL_TYPESCRIPT=0
INSTALL_FILE=0
INSTALL_RPC=0
INSTALL_WASM=0
INSTALL_JAVA=0
INSTALL_C=0
INSTALL_COBOL=0
INSTALL_SWIG=0
INSTALL_METACALL=0
INSTALL_PACK=0
INSTALL_COVERAGE=0
INSTALL_CLANGFORMAT=0
SHOW_HELP=0
PROGNAME=$(basename $0)

# Linux Distro detection
if [ -f /etc/os-release ]; then # Either Debian or Ubuntu
	# Cat file | Get the ID field | Remove 'ID=' | Remove leading and trailing spaces
	LINUX_DISTRO=$(cat /etc/os-release | grep "^ID=" | cut -f2- -d= | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
else
	# TODO: Implement more distros or better detection
	LINUX_DISTRO=unknown
fi

# Base packages
sub_apt(){
	echo "configure apt"
	cd $ROOT_DIR
	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends build-essential git cmake libgtest-dev wget apt-utils apt-transport-https gnupg dirmngr ca-certificates
}

# Swig
sub_swig(){
	echo "configure swig"
	cd $ROOT_DIR
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends g++ libpcre3-dev tar

	wget http://prdownloads.sourceforge.net/swig/swig-4.0.1.tar.gz

	tar -xzf swig-4.0.1.tar.gz
	cd swig-4.0.1
	./configure --prefix=/usr/local
	make
	$SUDO_CMD make install
	cd ..
	rm -rf swig-4.0.1

	# Install Python Port Dependencies (TODO: This must be transformed into pip3 install metacall)
	$SUDO_CMD pip3 install setuptools


}

# Python
sub_python(){
	echo "configure python"
	cd $ROOT_DIR
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends python3 python3-dev python3-pip
	$SUDO_CMD pip3 install requests
	$SUDO_CMD pip3 install setuptools
	$SUDO_CMD pip3 install wheel
	$SUDO_CMD pip3 install rsa
	$SUDO_CMD pip3 install fn
	$SUDO_CMD pip3 install scipy
	$SUDO_CMD pip3 install numpy
	$SUDO_CMD pip3 install scikit-learn
	$SUDO_CMD pip3 install joblib
}

# Ruby
sub_ruby(){
	echo "configure ruby"
	cd $ROOT_DIR

	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends ruby2.7 ruby2.7-dev

	# TODO: Review conflict with NodeJS (currently rails test is disabled)
	#wget https://deb.nodesource.com/setup_4.x | $SUDO_CMD bash -
	#$SUDO_CMD apt-get -y --no-install-recommends install nodejs
	#$SUDO_CMD gem install rails
}

# Rust
sub_rust(){
	echo "configure rust"
	cd $ROOT_DIR
	# install curl
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends curl
	curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly-2021-12-04 --profile default
}

# RapidJSON
sub_rapidjson(){
	echo "configure rapidjson"
	cd $ROOT_DIR
	git clone https://github.com/miloyip/rapidjson.git
	cd rapidjson
	git checkout v1.1.0
	mkdir build
	cd build
	cmake -DRAPIDJSON_BUILD_DOC=Off -DRAPIDJSON_BUILD_EXAMPLES=Off -DRAPIDJSON_BUILD_TESTS=Off ..
	make
	$SUDO_CMD make install
	cd ../.. && rm -rf ./rapidjson
}

# FuncHook
sub_funchook(){
	echo "configure funchook"
	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends cmake
}

# NetCore
sub_netcore(){
	echo "configure netcore"
	cd $ROOT_DIR

	# Debian Stretch

	$SUDO_CMD apt-get update && apt-get $APT_CACHE_CMD install -y --no-install-recommends \
		libc6 libcurl3 libgcc1 libgssapi-krb5-2 libicu57 liblttng-ust0 libssl1.0.2 libstdc++6 libunwind8 libuuid1 zlib1g

	# Install .NET Sdk
	DOTNET_SDK_VERSION=1.1.11
	DOTNET_SDK_DOWNLOAD_URL=https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$DOTNET_SDK_VERSION/dotnet-dev-debian.9-x64.$DOTNET_SDK_VERSION.tar.gz

	wget $DOTNET_SDK_DOWNLOAD_URL -O dotnet.tar.gz
	mkdir -p /usr/share/dotnet
	tar -zxf dotnet.tar.gz -C /usr/share/dotnet
	rm dotnet.tar.gz
	ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

	# Trigger the population of the local package cache
	mkdir warmup
	cd warmup
	dotnet new
	cd ..
	rm -rf warmup
	rm -rf /tmp/NuGetScratch
}

# NetCore 2
sub_netcore2(){
	echo "configure netcore 2"
	cd $ROOT_DIR

	# Set up repository
	wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
	$SUDO_CMD dpkg -i packages-microsoft-prod.deb
	rm packages-microsoft-prod.deb

	# Install .NET Core Sdk
	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends apt-transport-https
	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends dotnet-sdk-2.2
}

# NetCore 5
sub_netcore5(){
	echo "configure netcore 5"
	cd $ROOT_DIR

	# Set up repository
	wget https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb -O packages-microsoft-prod.deb
	$SUDO_CMD dpkg -i packages-microsoft-prod.deb
	rm packages-microsoft-prod.deb

	# Install .NET Core Sdk
	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends apt-transport-https
	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends dotnet-sdk-5.0
}

# V8 Repository
sub_v8repo(){
	echo "configure v8 from repository"
	cd $ROOT_DIR
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends software-properties-common

	# V8 5.1
	if [ $INSTALL_V8REPO51 = 1 ]; then
		$SUDO_CMD sh -c "echo \"deb http://ppa.launchpad.net/pinepain/libv8-archived/ubuntu trusty main\" > /etc/apt/sources.list.d/libv851.list"
		$SUDO_CMD sh -c "echo \"deb http://archive.ubuntu.com/ubuntu trusty main\" > /etc/apt/sources.list.d/libicu52.list"
		$SUDO_CMD apt-get update
		$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends --allow-unauthenticated libicu52 libv8-5.1.117 libv8-5.1-dev
	fi

	# V8 5.4
	if [ $INSTALL_V8REPO54 = 1 ]; then
		$SUDO_CMD sh -c "echo \"deb http://ppa.launchpad.net/pinepain/libv8-5.4/ubuntu xenial main\" > /etc/apt/sources.list.d/libv854.list"
		wget http://launchpadlibrarian.net/234847357/libicu55_55.1-7_amd64.deb
		$SUDO_CMD dpkg -i libicu55_55.1-7_amd64.deb
		$SUDO_CMD apt-get update
		$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends --allow-unauthenticated libicu55 libv8-5.4-dev
		$SUDO_CMD rm libicu55_55.1-7_amd64.deb
	fi

	# V8 5.2
	if [ $INSTALL_V8REPO52 = 1 ]; then
		$SUDO_CMD add-apt-repository -y ppa:pinepain/libv8-5.2
		$SUDO_CMD apt-get update
		$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends libicu55 libv8-5.2-dev
	fi

	# V8 5.7
	if [ $INSTALL_V8REPO57 = 1 ]; then
		$SUDO_CMD add-apt-repository -y ppa:pinepain/libv8-5.7
		$SUDO_CMD apt-get update
		$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends libicu55 libv8-5.7-dev
	fi

	# V8 5.8
	if [ $INSTALL_V8REPO58 = 1 ]; then
		$SUDO_CMD sh -c "echo \"deb http://ppa.launchpad.net/pinepain/libv8-archived/ubuntu trusty main\" > /etc/apt/sources.list.d/libv8-archived.list"
		$SUDO_CMD apt-get update
		$SUDO_CMD apt-get $APT_CACHE_CMD -y --no-install-recommends libicu57 libv8-5.8.283 libv8-5.8-dev
	fi
}

# V8
sub_v8(){
	echo "configure v8"
	cd $ROOT_DIR
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends python
	git clone https://chromium.googlesource.com/chromium/tools/depot_tools.git
	export PATH=`pwd`/depot_tools:"$PATH"

	export GYP_DEFINES="snapshot=on linux_use_bundled_gold=0 linux_use_gold_flags=0 component=shared_library"

	fetch v8
	cd v8
	git checkout 5.1-lkgr
	gclient sync

	patch build/all.gyp $ROOT_DIR/nobuildtest.patch
	GYP_DEFINES="snapshot=on linux_use_bundled_gold=0 linux_use_gold_flags=0 component=shared_library" make library=shared native
}

# NodeJS
sub_nodejs(){
	# TODO: Review conflicts with Ruby Rails and NodeJS 4.x
	echo "configure nodejs"
	cd $ROOT_DIR
	$SUDO_CMD apt-get update

	# Install python to build node (gyp)
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends python3 g++ make nodejs npm curl

	# Update npm and node-gyp
	$SUDO_CMD npm i npm@latest -g
	$SUDO_CMD npm i node-gyp@latest -g
}

# TypeScript
sub_typescript(){
	echo "configure typescript"

	# Install React dependencies in order to run the tests
	$SUDO_CMD npm i react@latest -g
	$SUDO_CMD npm i react-dom@latest -g
}

# File
sub_file(){
	echo "configure file"
}

# RPC
sub_rpc(){
	echo "cofingure rpc"
	cd $ROOT_DIR

	# Install development files and documentation for libcurl (OpenSSL flavour)
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends libcurl4-openssl-dev
}

# WebAssembly
sub_wasm(){
	echo "configure webassembly"

	# TODO

	# $SUDO_CMD apt-get update
	# $SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends --fix-broken lib32gcc-6-dev g++-multilib
}

# Java
sub_java(){
	echo "configure java"

	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends default-jre default-jdk
}

# C
sub_c(){
	echo "configure c"

	LLVM_VERSION_STRING=11
	UBUNTU_CODENAME=""
	CODENAME_FROM_ARGUMENTS=""
	# Obtain VERSION_CODENAME and UBUNTU_CODENAME (for Ubuntu and its derivatives)
	source /etc/os-release
	DISTRO=${DISTRO,,}
	case ${DISTRO} in
		debian)
			if [[ "${VERSION}" == "unstable" ]] || [[ "${VERSION}" == "testing" ]]; then
				CODENAME=unstable
				LINKNAME=
			else
				# "stable" Debian release
				CODENAME=${VERSION_CODENAME}
				LINKNAME=-${CODENAME}
			fi
			;;
		*)
			# ubuntu and its derivatives
			if [[ -n "${UBUNTU_CODENAME}" ]]; then
				CODENAME=${UBUNTU_CODENAME}
				if [[ -n "${CODENAME}" ]]; then
					LINKNAME=-${CODENAME}
				fi
			fi
			;;
	esac

	wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | $SUDO_CMD apt-key add
	$SUDO_CMD sh -c "echo \"deb http://apt.llvm.org/${CODENAME}/ llvm-toolchain${LINKNAME}-${LLVM_VERSION_STRING} main\" >> /etc/apt/sources.list"
	$SUDO_CMD sh -c "echo \"deb-src http://apt.llvm.org/${CODENAME}/ llvm-toolchain${LINKNAME}-${LLVM_VERSION_STRING} main\" >> /etc/apt/sources.list"
	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get install -y --no-install-recommends libffi-dev libclang-${LLVM_VERSION_STRING}-dev
}

# Cobol
sub_cobol(){
	echo "configure cobol"

	if [ "${LINUX_DISTRO}" == "debian" ]; then
		echo "deb http://deb.debian.org/debian/ unstable main" | $SUDO_CMD tee -a /etc/apt/sources.list > /dev/null

		$SUDO_CMD apt-get update
		$SUDO_CMD apt-get $APT_CACHE_CMD -t unstable install -y --no-install-recommends gnucobol

		# Remove unstable from sources.list
		$SUDO_CMD head -n -2 /etc/apt/sources.list
	elif [ "${LINUX_DISTRO}" == "ubuntu" ]; then
		$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends open-cobol
	fi
}

# MetaCall
sub_metacall(){
	# TODO: Update this or deprecate it
	echo "configure metacall"
	cd $ROOT_DIR
	git clone https://github.com/metacall/core.git
	mkdir core/build && cd core/build

	if [ $INSTALL_NETCORE = 1 ]; then
		NETCORE_VERSION=1.1.10
	elif [ INSTALL_NETCORE2 = 1 ]; then
		NETCORE_VERSION=2.2.8
	elif [ INSTALL_NETCORE5 = 1 ]; then
		NETCORE_VERSION=5.0.17
	else
		NETCORE_VERSION=0
	fi

	cmake -Wno-dev ../ -DOPTION_BUILD_EXAMPLES=off -DOPTION_BUILD_LOADERS_PY=on -DOPTION_BUILD_LOADERS_RB=on -DOPTION_BUILD_LOADERS_CS=on -DOPTION_BUILD_LOADERS_JS=on -DCMAKE_BUILD_TYPE=Release -DDOTNET_CORE_PATH=/usr/share/dotnet/shared/Microsoft.NETCore.App/$NETCORE_VERSION/
	make
	make test && echo "test ok!"

	echo "configure with cmake .. <options>"
}

# Pack
sub_pack(){
	echo "configure pack"
	cd $ROOT_DIR
	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get $APT_CACHE_CMD install -y --no-install-recommends rpm
}

# Coverage
sub_coverage(){
	echo "configure coverage"
	cd $ROOT_DIR
	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get install -y --no-install-recommends lcov
}

# Clang format
sub_clangformat(){
	echo "configure clangformat"
	cd $ROOT_DIR

	LLVM_VERSION_STRING=12
	UBUNTU_CODENAME=""
	CODENAME_FROM_ARGUMENTS=""
	# Obtain VERSION_CODENAME and UBUNTU_CODENAME (for Ubuntu and its derivatives)
	source /etc/os-release
	DISTRO=${DISTRO,,}
	case ${DISTRO} in
		debian)
			if [[ "${VERSION}" == "unstable" ]] || [[ "${VERSION}" == "testing" ]]; then
				CODENAME=unstable
				LINKNAME=
			else
				# "stable" Debian release
				CODENAME=${VERSION_CODENAME}
				LINKNAME=-${CODENAME}
			fi
			;;
		*)
			# ubuntu and its derivatives
			if [[ -n "${UBUNTU_CODENAME}" ]]; then
				CODENAME=${UBUNTU_CODENAME}
				if [[ -n "${CODENAME}" ]]; then
					LINKNAME=-${CODENAME}
				fi
			fi
			;;
	esac

	wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | $SUDO_CMD apt-key add
	$SUDO_CMD sh -c "echo \"deb http://apt.llvm.org/${CODENAME}/ llvm-toolchain${LINKNAME}-${LLVM_VERSION_STRING} main\" >> /etc/apt/sources.list"
	$SUDO_CMD sh -c "echo \"deb-src http://apt.llvm.org/${CODENAME}/ llvm-toolchain${LINKNAME}-${LLVM_VERSION_STRING} main\" >> /etc/apt/sources.list"
	$SUDO_CMD apt-get update
	$SUDO_CMD apt-get install -y --no-install-recommends clang-format-${LLVM_VERSION_STRING}
	$SUDO_CMD ln -s /usr/bin/clang-format-${LLVM_VERSION_STRING} /usr/bin/clang-format
}

# Install
sub_install(){
	if [ $RUN_AS_ROOT = 1 ]; then
		SUDO_CMD=""
	fi
	if [ $APT_CACHE = 1 ]; then
		APT_CACHE_CMD=-o dir::cache::archives="$APT_CACHE_DIR"
	fi
	if [ $INSTALL_APT = 1 ]; then
		sub_apt
	fi
	if [ $INSTALL_PYTHON = 1 ]; then
		sub_python
	fi
	if [ $INSTALL_RUBY = 1 ]; then
		sub_ruby
	fi
	if [ $INSTALL_RUST = 1 ]; then
		sub_rust
	fi
	if [ $INSTALL_RAPIDJSON = 1 ]; then
		sub_rapidjson
	fi
	if [ $INSTALL_FUNCHOOK = 1 ]; then
		sub_funchook
	fi
	if [ $INSTALL_NETCORE = 1 ]; then
		sub_netcore
	fi
	if [ $INSTALL_NETCORE2 = 1 ]; then
		sub_netcore2
	fi
	if [ $INSTALL_NETCORE5 = 1 ]; then
		sub_netcore5
	fi
	if [ $INSTALL_V8 = 1 ]; then
		sub_v8
	fi
	if [ $INSTALL_V8REPO = 1 ]; then
		sub_v8repo
	fi
	if [ $INSTALL_NODEJS = 1 ]; then
		sub_nodejs
	fi
	if [ $INSTALL_TYPESCRIPT = 1 ]; then
		sub_typescript
	fi
	if [ $INSTALL_FILE = 1 ]; then
		sub_file
	fi
	if [ $INSTALL_RPC = 1 ]; then
		sub_rpc
	fi
	if [ $INSTALL_WASM = 1 ]; then
		sub_wasm
	fi
	if [ $INSTALL_JAVA = 1 ]; then
		sub_java
	fi
	if [ $INSTALL_C = 1 ]; then
		sub_c
	fi
	if [ $INSTALL_COBOL = 1 ]; then
		sub_cobol
	fi
	if [ $INSTALL_SWIG = 1 ]; then
		sub_swig
	fi
	if [ $INSTALL_METACALL = 1 ]; then
		sub_metacall
	fi
	if [ $INSTALL_PACK = 1 ]; then
		sub_pack
	fi
	if [ $INSTALL_COVERAGE = 1 ]; then
		sub_coverage
	fi
	if [ $INSTALL_CLANGFORMAT = 1 ]; then
		sub_clangformat
	fi
	echo "install finished in workspace $ROOT_DIR"
}

# Configuration
sub_options(){
	for var in "$@"
	do
		if [ "$var" = 'root' ]; then
			echo "running as root"
			RUN_AS_ROOT=1
		fi
		if [ "$var" = 'cache' ]; then
			echo "apt caching selected"
			APT_CACHE=1
		fi
		if [ "$var" = 'base' ]; then
			echo "apt selected"
			INSTALL_APT=1
		fi
		if [ "$var" = 'python' ]; then
			echo "python selected"
			INSTALL_PYTHON=1
		fi
		if [ "$var" = 'ruby' ]; then
			echo "ruby selected"
			INSTALL_RUBY=1
		fi
		if [ "$var" = 'rust' ]; then
			echo "rust selected"
			INSTALL_RUST=1
		fi
		if [ "$var" = 'netcore' ]; then
			echo "netcore selected"
			INSTALL_NETCORE=1
		fi
		if [ "$var" = 'netcore2' ]; then
			echo "netcore 2 selected"
			INSTALL_NETCORE2=1
		fi
		if [ "$var" = 'netcore5' ]; then
			echo "netcore 5 selected"
			INSTALL_NETCORE5=1
		fi
		if [ "$var" = 'rapidjson' ]; then
			echo "rapidjson selected"
			INSTALL_RAPIDJSON=1
		fi
		if [ "$var" = 'funchook' ]; then
			echo "funchook selected"
			INSTALL_FUNCHOOK=1
		fi
		if [ "$var" = 'v8' ] || [ "$var" = 'v8rep54' ]; then
			echo "v8 selected"
			INSTALL_V8REPO=1
			INSTALL_V8REPO54=1
		fi
		if [ "$var" = 'v8rep57' ]; then
			echo "v8 selected"
			INSTALL_V8REPO=1
			INSTALL_V8REPO57=1
		fi
		if [ "$var" = 'v8rep58' ]; then
			echo "v8 selected"
			INSTALL_V8REPO=1
			INSTALL_V8REPO58=1
		fi
		if [ "$var" = 'v8rep52' ]; then
			echo "v8 selected"
			INSTALL_V8REPO=1
			INSTALL_V8REPO52=1
		fi
		if [ "$var" = 'v8rep51' ]; then
			echo "v8 selected"
			INSTALL_V8REPO=1
			INSTALL_V8REPO51=1
		fi
		if [ "$var" = 'nodejs' ]; then
			echo "nodejs selected"
			INSTALL_NODEJS=1
		fi
		if [ "$var" = 'typescript' ]; then
			echo "typescript selected"
			INSTALL_TYPESCRIPT=1
		fi
		if [ "$var" = 'file' ]; then
			echo "file selected"
			INSTALL_FILE=1
		fi
		if [ "$var" = 'rpc' ]; then
			echo "rpc selected"
			INSTALL_RPC=1
		fi
		if [ "$var" = 'wasm' ]; then
			echo "wasm selected"
			INSTALL_WASM=1
		fi
		if [ "$var" = 'java' ]; then
			echo "java selected"
			INSTALL_JAVA=1
		fi
		if [ "$var" = 'c' ]; then
			echo "c selected"
			INSTALL_C=1
		fi
		if [ "$var" = 'cobol' ]; then
			echo "cobol selected"
			INSTALL_COBOL=1
		fi
		if [ "$var" = 'swig' ]; then
			echo "swig selected"
			INSTALL_SWIG=1
		fi
		if [ "$var" = 'metacall' ]; then
			echo "metacall selected"
			INSTALL_METACALL=1
		fi
		if [ "$var" = 'pack' ]; then
			echo "pack selected"
			INSTALL_PACK=1
		fi
		if [ "$var" = 'coverage' ]; then
			echo "coverage selected"
			INSTALL_COVERAGE=1
		fi
		if [ "$var" = 'clangformat' ]; then
			echo "clangformat selected"
			INSTALL_CLANGFORMAT=1
		fi
	done
}

# Help
sub_help() {
	echo "Usage: `basename "$0"` list of component"
	echo "Components:"
	echo "	root"
	echo "	cache"
	echo "	base"
	echo "	python"
	echo "	ruby"
	echo "	netcore"
	echo "	netcore2"
	echo "	netcore5"
	echo "	rapidjson"
	echo "	funchook"
	echo "	v8"
	echo "	v8rep51"
	echo "	v8rep54"
	echo "	v8rep57"
	echo "	v8rep58"
	echo "	nodejs"
	echo "	typescript"
	echo "	file"
	echo "	rpc"
	echo "	wasm"
	echo "	java"
	echo "	c"
	echo "	cobol"
	echo "	swig"
	echo "	metacall"
	echo "	pack"
	echo "	coverage"
	echo "	clangformat"
	echo ""
}

case "$#" in
	0)
		sub_help
		;;
	*)
		sub_options $@
		sub_install
		;;
esac
