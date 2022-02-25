#!/bin/bash

echo '==============================================================='
echo '========================== VMD Store =========================='
echo '==============================================================='

echo '====== This script is going to install VMD Store for you. ====='
echo '==============================================================='
echo '==============================================================='
echo '   Where do you want to install the VMD Store?'
echo '        Please provide a full path:'

read installPath

if [ ! -d "$installPath" ]; then
    echo 'The path provided is not valid: "'$installPath'"'
    echo 'Abort!'
    exit
fi

echo 'The VMD Store installation path: "'$installPath'"'
echo '==============================================================='
echo 'Checking last version of VMD Store...'
versionFile=$(curl -s https://github.com/BioSIM-Research-Group/vmdStore/releases/latest)
version=$(awk -F 'tag/' '{print $2}' <<< $versionFile | awk -F '"' '{print $1}')
echo 'VMD Store version '$version' was found online.'
echo '==============================================================='
echo 'Downloading...'
wget -q "https://github.com/BioSIM-Research-Group/vmdStore/archive/$version.zip" -O "$installPath/vmdStore.zip"
echo 'Download Complete!'
echo '==============================================================='
echo 'Installing...'
unzip -q "$installPath/vmdStore.zip" -d "$installPath/tmp_vmdStore"
cp -r "$installPath/tmp_vmdStore/vmdStore-$version/vmdStore" "$installPath"
rm -rf "$installPath/tmp_vmdStore" "$installPath/vmdStore.zip"
sed -i -- "s/XXversionXX/$version/g" "$installPath/vmdStore/vmdStore.rc"
path="$installPath/vmdStore"
sed -i -- "s|none|\"$path\"|g" "$installPath/vmdStore/vmdStore.rc"
echo '  The following lines were added to the file '"$HOME/.vmdrc"
echo "      ##### VMD Store ## START #####"
echo "      play \"$path/vmdStore.rc\""
echo "      ##### VMD Store ## END #####"
echo "      menu main on"

echo "##### VMD Store ## START #####" >> "$HOME/.vmdrc"
echo "play \"$path/vmdStore.rc\"" >> "$HOME/.vmdrc"
echo "##### VMD Store ## END #####" >> "$HOME/.vmdrc"
echo "menu main on" >> "$HOME/.vmdrc"
echo 'Installation Complete!'
echo '==============================================================='
echo 'Enjoy the VMD Store under the "Extensions" > "VMD Store" > "VMD Store" menu of VMD.'
echo '==============================================================='
echo 'VMD Store | Developed by Henrique S. Fernandes and Nuno M.F.S.A. Cerqueira'
echo 'Contact: hfernandes@med.up.pt'