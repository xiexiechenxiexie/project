#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

echo $DIR

if [ -d $DIR/ios ]; then
rm -r $DIR/ios
fi

if [ -d $DIR/src ]; then
rm -r $DIR/src
fi

#source ~/.profile

mkdir "$DIR/ios"
mkdir "$DIR/src"
mkdir "$DIR/ios/srcTmp"
mkdir "$DIR/ios/resTmp"

echo $DIR/../../

cp -R $DIR/../../src $DIR/ios/srcTmp
cp -R $DIR/../../src $DIR/ios/resTmp

php "$DIR/lib/compile_scripts.php" $* -i $DIR/ios/srcTmp -o $DIR/ios/resources_src -m files -b 64 -ek YangeIt -es HsGame


php "$DIR/lib/encrypt_res.php" $* -i $DIR/ios/resTmp -o  $DIR/ios/resources_res -ek YangeIt -es HsGame


if [ -d $DIR/ios/srcTmp ]; then
rm -r $DIR/ios/srcTmp
fi

if [ -d $DIR/ios/resTmp ]; then
rm -r $DIR/ios/resTmp
fi

cp -R $DIR/ios/resources_res/src $DIR
cp -R $DIR/ios/resources_src/src $DIR

if [ -d $DIR/ios ]; then
rm -r $DIR/ios
fi


