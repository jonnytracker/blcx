#!/bin/bash
VERSION=$1
if [ -x ${VERSION} ];
then
	echo VERSION not defined
	exit 1
fi
APPLICATION="blcx-coin"
PACKAGE=${APPLICATION}-client-${VERSION}
echo PACKAGE="${PACKAGE}"
CHANGELOG=nxt-clone-client-${VERSION}.changelog.txt
OBFUSCATE=$2
MACVERSION=$3
if [ -x ${MACVERSION} ];
then
MACVERSION=${VERSION}
fi
echo MACVERSION="${MACVERSION}"

FILES="changelogs conf html lib resource contrib"
FILES="${FILES} ${APPLICATION}.exe ${APPLICATION}service.exe"
FILES="${FILES} 3RD-PARTY-LICENSES.txt AUTHORS.txt LICENSE.txt"
FILES="${FILES} DEVELOPERS-GUIDE.md OPERATORS-GUIDE.md README.md README.txt USERS-GUIDE.md"
FILES="${FILES} mint.bat mint.sh run.bat run.sh run-tor.sh run-desktop.sh start.sh stop.sh compact.sh compact.bat sign.sh sign.bat passphraseRecovery.sh passphraseRecovery.bat"
FILES="${FILES} nxt.policy nxtdesktop.policy Wallet.url Dockerfile"

echo compile
./compile.sh
rm -rf html/doc/*
rm -rf ${APPLICATION}
rm -rf ${PACKAGE}.jar
rm -rf ${PACKAGE}.exe
rm -rf ${PACKAGE}.zip
mkdir -p ${APPLICATION}/
mkdir -p ${APPLICATION}/logs
mkdir -p ${APPLICATION}/addons/src

if [ "${OBFUSCATE}" = "obfuscate" ]; 
then
echo obfuscate
~/proguard/proguard5.3.3/bin/proguard.sh @nxt.pro
mv ../nxt.map ../nxt.map.${VERSION}
else
FILES="${FILES} classes src JPL-NRS.pdf"
FILES="${FILES} compile.sh javadoc.sh jar.sh package.sh"
FILES="${FILES} win-compile.sh win-javadoc.sh win-package.sh"
echo javadoc
./javadoc.sh
fi
echo copy resources
cp installer/lib/JavaExe.exe ${APPLICATION}.exe
cp installer/lib/JavaExe.exe ${APPLICATION}service.exe
cp -a ${FILES} ${APPLICATION}
cp -a logs/placeholder.txt ${APPLICATION}/logs
echo gzip
for f in `find ${APPLICATION}/html -name *.gz`
do
	rm -f "$f"
done
for f in `find ${APPLICATION}/html -name *.html -o -name *.js -o -name *.css -o -name *.json  -o -name *.ttf -o -name *.svg -o -name *.otf`
do
	gzip -9c "$f" > "$f".gz
done
cd nxt
echo generate jar files
../jar.sh
echo package installer Jar
../installer/build-installer.sh ../${PACKAGE}
cd -
rm -rf ${APPLICATION}

echo bundle a dmg file	
/Library/Java/JavaVirtualMachines/jdk1.8.0_162.jdk/Contents/Home/bin/javapackager -deploy -outdir . -outfile ${APPLICATION}-client -name ${APPLICATION}-installer -width 34 -height 43 -native dmg -srcfiles ${PACKAGE}.jar -appclass com.izforge.izpack.installer.bootstrap.Installer -v -Bmac.category=Business -Bmac.CFBundleIdentifier=org.nxt.client.installer -Bmac.CFBundleName=${APPLICATION}-Installer -Bmac.CFBundleVersion=${MACVERSION} -BappVersion=${MACVERSION} -Bicon=installer/AppIcon.icns -Bmac.signing-key-developer-id-app="Developer ID Application: Stichting NXT (YU63QW5EFW)" > installer/javapackager.log 2>&1
