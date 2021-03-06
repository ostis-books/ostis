#!/bin/bash

red="\e[1;31m"  # Red B
blue="\e[1;34m" # Blue B
green="\e[0;32m"

bwhite="\e[47m" # white background

rst="\e[0m"     # Text reset

st=1

stage()
{
    echo -en "$green[$st] "$blue"$1...$rst\n"
    let "st += 1"
}

clone_project()
{
    if [ ! -d "../$2" ]; then
        echo -en $green"Clone $2$rst\n"
        git clone $1 ../$2
        cd ../$2
        git checkout $3
        cd -
    else
        echo -en "You can update "$green"$2"$rst" manually$rst\n"
    fi
}


stage "Clone projects"

clone_project https://github.com/ostis-books/sc-machine.git sc-machine book_search
clone_project https://github.com/ostis-books/kb.git kb master

clone_project https://github.com/Ivan-Zhukau/sc-web.git sc-web master
clone_project https://github.com/ShunkevichDV/ims.ostis.kb.git ims.ostis.kb master

clone_project https://github.com/ostis-books/ostis-components.git components master

stage "Prepare projects"

prepare()
{
    echo -en $green$1$rst"\n"
}


prepare "sc-machine"
cd ../sc-machine/scripts
./install_deps_ubuntu.sh

sudo apt-get install redis-server

./clean_all.sh
./make_all.sh
cd -


prepare "sc-web"
sudo apt-get install python-dev # required for numpy module
cd ../sc-web/scripts
./install_deps_ubuntu.sh
./install_nodejs_dependence.sh
cd -
cd ../sc-web
npm install
grunt build
cd -
echo -en $green"Copy server.conf"$rst"\n"
cp -f ../config/server.conf ../sc-web/server/


kb_components_path=../../kb/books_ui/components

prepare_component()
{
    prepare "$1"

    cd "../components/$1"

    mkdir -p "$kb_components_path/$1"

    mv -f *.scs* "$kb_components_path/$1/"
    mv -f htmls "$kb_components_path/$1/"
    mv -f update_component.sh "../../scripts/update_$1.sh"
    cd -
    chmod +x "update_$1.sh"
    "./update_$1.sh"
}

prepare_component note_component
prepare_component book_search_component
prepare_component tag_cloud_component
prepare_component book_search_unified_component
prepare_component similar_books_component
prepare_component book_search_by_events_component

stage "Build knowledge base"

./build_kb.sh
