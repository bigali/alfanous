#
# This is Alfanous Makefile
#



## Global Version of the project, must be updated in each significant change in 
## the API & Desktop Gui
VERSION="0.7.00"

## API path, API contains all python packages 
API_PATH="./src/"

## Importer package path, the importer is the responsible of downloading quranic
## resources, updating them , indexing them.
QIMPORT=$(API_PATH)"alfanous-import/main.py" 
	
## Dynamic resources, are some auto-generated python modules that contain some 
## linguistic resources on the form of python dictionaries		
DYNAMIC_RESOURCES_PATH=$(API_PATH)"alfanous/dynamic_resources/"

## resources & configuration files 
CONFIGS_PATH=$(API_PATH)"alfanous/configs/"
RESOURCES_PATH=$(API_PATH)"alfanous/resources/"

## Databases file, the databases mainly store the Quranic data in a middle 
## structure before indexing it  
DB_PATH="./resources/databases/"

## Store is the place where we're storing the Quranic data in its original 
## structure (raw data)
STORE_PATH="./store/"

## Index path, is where we put the generated indexes
INDEX_PATH=$(API_PATH)"alfanous/indexes/"

## Desktop Gui interface path
DESKTOP_INTERFACE_PATH=$(API_PATH)"alfanous-desktop/"
## QT UI & RC files paths, destined to be compiled & used by alfanousDesktop
QT_UI_PATH=$(DESKTOP_INTERFACE_PATH)"UI/"
QT_RC_PATH=$(DESKTOP_INTERFACE_PATH)"images/"


## Path of Web User Interface for mobiles 
MOBILE_WUI_PATH=./interfaces/web/mobile_wui/
## Web User interface path
WUI_PATH=./interfaces/web/wui/


##  Installation Paths:
PREFIX?=/usr
CONFIG_INSTALL_PATH="$(DESTDIR)$(PREFIX)/share/alfanous-config/"
INDEX_INSTALL_PATH="$(DESTDIR)$(PREFIX)/share/alfanous-indexes/"
WEB_INSTALL_PATH=$(DESTDIR)/var/www/alfanous-web/
WEB_CGI_INSTALL_PATH=$(WEB_INSTALL_PATH)cgi/


## default target, it's what to do if you typed "make" without target
default: 
	@echo "choose a target:"
	@echo "download_all \n\t to download all Quranic resources that we can't \n\t include in Git or tarball because of license or huge size" 
	@echo "build \n\t to build all indexes, update all resources, qt files, \n\t localization files, help files"
	@echo "tarball_data \n\t to make a tarball that contains all downloaded \n\t and generated data"
	@echo "dist_all \n\t to generate all distribution files for the API and \n\t the Desktop interface"
	@echo "install_all \n\t install all interfaces on your system. don't use \n\t it unless you know what you are doing!! (deprecated)"
	 
	

## This target englob all the targets on this makefile
## it may help when you are going to make a release
## it will do every thing:
# 1. download all Quranic resources that we can't include in Git or tarball because of license or huge size
# 2. build all indexes, update all resources, qt files,  localization files, help files
# 3. make a tarball that contains all downloaded and generated data
# 4. generate all possible distribution files for all interfaces: API, Desktop interface

## Kaboom! @TODO: must test this well
all:  download_all   build   tarball_data  dist_all  clean  #install_all	 


## this target is to build all what have to be built:
# 1. Update Quranic resources needed for indexing phase, see update_pre_build
# 2. Generate all Indexes, see  index_all
# 3. Generate all spelling dictionaries, see speller_all
# 4. Update all resources that must be updated after indexing phase or independently, see  update_post_build
# 5. Build qt resource files, see qt_all
# 6. Generate localization files, see local_pot_all
# 7. Generate help files, see help_all
build:  update_pre_build index_all speller_all update_post_build qt_all local_pot_all help_all


## clean temporary files after a building operation
# TODO	add all what has to be cleaned!
clean:
	@echo "Cleaning..." 
	rm -rf `find . -type f -name Thumbs.db`
	#rm -rf `find . -name *~`
	rm -rf `find . -name *.pyc`
	rm -rf `find . -name *.pyo`
	rm -rf `find . -type d -name *.egg-info`
	

## download Quranic resources needed for Alfanous project, which are:
# 1. Quran translations from zekr.org, see download_translations
# 2. 
download_all: download_translations download_recitations download_quranic_corpus download_tanzil local_mo_download

download_translations:
	#  download from  http://zekr.org/resources.html to ./store/traductions
	cd $(STORE_PATH)Translations;  wget -i translations.list

download_recitations:
	#  auto download from  http://zekr.org/resources.html to ./store/recitations  + VerseByVerse recitations list
	@echo "todo"

download_quranic_corpus:
	# Qimport.Downloader
	@echo "todo"

download_tanzil:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -d tanzil_simple_clean $(STORE_PATH)tanzil_simple_clean.xml
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -d tanzil_uthmani $(STORE_PATH)tanzil_uthmani.xml



##  update resources that must be updated after (or independent to) indexing phase, which are:
# 1. api information, see update_information
# 2. globl hints (deprecated), see update_hints
# 3. list of indexed translations, see update_translations_indexed_list
# 4. list of offline recitations, see update_recitations_offline_list
# 5. list of online recitations, see update_recitations_online_list  
update_post_build:  update_dynamic_resources_postbuild  update_information update_hints update_translations_indexed_list update_recitations_offline_list #update_recitations_online_list   

##  update resources that must be updated before indexing phase, which are:
# 1. Quranic Arabic Corpus, see update_quranic_corpus
# 2. Linguistic resources on the form of python dictionarries to accelerate the loading , see update_dynamic_resources
# 3. List of translations to be downloaded, see  update_translations_to_download_list
update_pre_build:  update_dynamic_resources_prebuild  update_translations_to_download_list #update_quranic_corpus

# update information manually 
update_information:
	nano $(RESOURCES_PATH)information.json

# update hints manually
update_hints:
	nano $(CONFIGS_PATH)hints.json

# update stats manually, to initiate it just leave it as an empty json object {}
# never leave it empty till fix that! TODO
update_stats:
	nano $(CONFIGS_PATH)stats.json 
	chmod 777 $(CONFIGS_PATH)stats.json 

# update downloading translation list manually
update_translations_to_download_list:
	nano $(STORE_PATH)Translations/translations.list

# update list of indexed translations automatically using Importer
update_translations_indexed_list:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -u translations $(INDEX_PATH)extend/ $(CONFIG_PATH)translations.json

# update quranic corpus in the database automatically using Importer
update_quranic_corpus:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -u wordqc $(STORE_PATH)quranic-corpus-morpology.xml $(DB_PATH)main.db

# update recitations offline list TODO
update_recitations_offline_list:
	@echo "todo"

# update recitations online list automatically from the project every ayah
update_recitations_online_list:
	cd $(CONFIGS_PATH); wget http://www.everyayah.com/data/recitations.js; mv recitations.js recitations.json

# update dynamic resources automatically , see transfer_prebuild, transfer_postbuild
update_dynamic_resources_prebuild: transfer_prebuild
update_dynamic_resources_postbuild: transfer_postbuild
	
## build dynamic_resources by transferring the data from database (or indexes) to python modules, this include:
# 1. [prebuild] arabic stop words, see transfer_stopwords
# 2. [prebuild] Quranic words synonyms, see transfer_synonyms
# 3. [prebuild] Word properties [root,type], see transfer_word_props
# 4. [prebuild] Derivtion levels of Qurnic words, see transfer_derivations
# 5. [prebuild] Field names mapping Arabic to English, see transfer_ara2eng_names
# 6. [prebuild] Quranic words mapping Standard to Uthmani, see transfer_standard2uthmani
# 7. [postbuild] Different vocalizations of each quranic word, see transfer_vocalizations
transfer_all: transfer_prebuild transfer_postbuild
transfer_prebuild: transfer_stopwords transfer_synonyms transfer_word_props transfer_derivations transfer_ara2eng_names transfer_standard2uthmani 
transfer_postbuild: transfer_vocalizations
	
transfer_stopwords:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -t stopwords $(DB_PATH)main.db $(DYNAMIC_RESOURCES_PATH)
	
transfer_synonyms:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -t synonyms $(DB_PATH)main.db $(DYNAMIC_RESOURCES_PATH)

transfer_word_props:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -t word_props $(DB_PATH)main.db $(DYNAMIC_RESOURCES_PATH)

transfer_derivations:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -t derivations $(DB_PATH)main.db $(DYNAMIC_RESOURCES_PATH)

transfer_vocalizations:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -t vocalizations $(DB_PATH)main.db $(INDEX_PATH)main/ $(DYNAMIC_RESOURCES_PATH)

transfer_ara2eng_names:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -t ara2eng_names $(DB_PATH)main.db $(DYNAMIC_RESOURCES_PATH)
	
transfer_standard2uthmani:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -t std2uth_words $(DB_PATH)main.db $(DYNAMIC_RESOURCES_PATH)
	


## build all indexes:
# 1. Main index that contains all information related to Ayah or Surah, see index_main
# 2. Extended index that contains Quranic translations and offline recitations, see index_extend
# 3. Word index, contains all information related to Word, see index_word
index_all: index_main index_extend #index_word 
	@echo "done;"

index_main:
	export PYTHONPATH=$(API_PATH) ;	rm -r $(INDEX_PATH)main/; python $(QIMPORT) -x main $(DB_PATH)main.db $(INDEX_PATH)main/

index_extend:
	export PYTHONPATH=$(API_PATH) ;	rm -r $(INDEX_PATH)extend/; python $(QIMPORT) -x extend $(STORE_PATH)Translations/ $(INDEX_PATH)extend/
	
index_word:
	export PYTHONPATH=$(API_PATH) ;	rm -r $(INDEX_PATH)word/; python $(QIMPORT) -x word $(DB_PATH)main.db $(INDEX_PATH)word/
	

## build all spellers:
# 1. Speller of ayah unvocalized standard text words, see speller_aya
# 2. Speller of subject fields (deprecated), see speller_subject
# 3. Speller of quranic unvocalized uthmani words, see speller_word
speller_all: speller_aya speller_subject #speller_word
	@echo "done;"

speller_aya:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -p aya  $(INDEX_PATH)main/

speller_subject:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -p subject  $(INDEX_PATH)main/

speller_word:
	export PYTHONPATH=$(API_PATH) ;	python $(QIMPORT) -p word  $(INDEX_PATH)word/
	


## build help based on those methods:
# 1. epydoc, see help_epydoc
# 2. sphinx, see help_sphinx
help_all: help_epydoc help_sphinx

help_epydoc:
	mkdir -p output/$(VERSION);cd $(API_PATH); epydoc   --html -v --graph all --no-sourcecode     --show-imports  -n alfanous -u alfanous.org  . ;  zip -9   alfanous-epydoc.zip ./html/* ;	mv -f alfanous-epydoc.zip ../output/$(VERSION)/ ; rm -r ./html
	
help_sphinx:
	mkdir -p output/$(VERSION);cd ./docs ; make dirhtml;  zip -9   alfanous-sphinx-doc.zip ./_build/dirhtml/* ; mv -f alfanous-sphinx-doc.zip ../output/$(VERSION)/ ; rm -r  ./_build/dirhtml

## Qt resources compilation, PyQt is needed: apt-get install pyqt4-dev-tools  pyqt-tools  
#  1. qrc files, see qt_rcc
#  2. ui files, see qt_uic
qt_all:	 qt_rcc qt_uic

qt_uic:
	pyuic4 -o $(DESKTOP_INTERFACE_PATH)aboutDlg_ui.py $(QT_UI_PATH)aboutDlg.ui
	pyuic4 -o $(DESKTOP_INTERFACE_PATH)preferencesDlg_ui.py $(QT_UI_PATH)preferencesDlg.ui
	pyuic4 -o temp.py $(QT_UI_PATH)mainform.ui #-x
	sed 's/\"MainWindow\"\,/\"MainWindow\"\,\_(/g' temp.py | sed 's/\, None\,/\)\, None\,/g'| sed 's/from PyQt4/LOCALPATH="\.\/locale\/"\nimport gettext\n\_\=gettext\.gettext\ngettext\.bindtextdomain\(\"alfanousQT\"\, LOCALPATH\)\ngettext\.textdomain\(\"alfanousQT\"\)\nfrom PyQt4/g'> $(DESKTOP_INTERFACE_PATH)mainform_ui.py
	rm temp.py

qt_rcc:
	pyrcc4 $(QT_RC_PATH)main.qrc -o $(DESKTOP_INTERFACE_PATH)main_rc.py

## build localization files, this include:
# 1. Desktop interface , see local_desktop_pot
# 2. Web User Interface for mobiles, see  local_mobile_pot
local_pot_all: local_desktop_pot local_mobile_pot

local_desktop_pot:
	xgettext $(DESKTOP_INTERFACE_PATH)*.py  --default-domain=alfanousQT --language=Python --keyword=n_ 
	mkdir -p localization/pot_files/alfanousQTv$(VERSION)
	mv alfanousQT.po localization/pot_files/alfanousQTv$(VERSION)/alfanousQTv$(VERSION).pot
	
local_mobile_pot:
	@if [ ! -d "./localization/pot_files/alfanousMWUIv$(VERSION)/" ]; then mkdir ./localization/pot_files/alfanousMWUIv$(VERSION)/; fi
	xgettext -kT_ --from-code utf-8 -L PHP --no-wrap --package-name="AlfanousMobileWUI" --package-version=$(VERSION) -d alfanousMWUI -o ./localization/pot_files/alfanousMWUIv$(VERSION)/alfanousMWUIv$(VERSION).pot $(MOBILE_WUI_PATH)*.php


## load mo files from launchpad automatically
local_mo_download:
	@echo "todo"
	#wget ; mv to /localization/locale

##   packaging all to:
# 1. Python egg files, see dist_egg_all
# 2. Debian/Ubuntu/Sabily DEB packages, see  dist_deb
# 3. Fedora/Ojuba RPM packages, see dist_rpm
# 4. Nokia Symbian sis package, see dist_sis
# 5. firefox toolbar xpi file, see dist_xpi
# 6. MacOS applications app, see  dist_app
dist_all: dist_egg_all dist_deb dist_rpm dist_sis dist_xpi  dist_app

## generate all extentions and API's eggs:
# 1. Alfanous main API, see dist_egg_api
# 2. PyCorpus [Quranic Corpus parser], see dist_egg_pycorpus
# 3. PyZekr [Zekr Translations models reader], see dist_egg_pyzekr
# 4. Alfanous Importer [Importing, Updating, Downloading, Indexing resources], see dist_egg_qimport
# 5. Alfanous Desktop Gui , see dist_egg_desktop
dist_egg_all: dist_egg_api  dist_egg_pycorpus  dist_egg_pyzekr dist_egg_qimport dist_egg_desktop
 

# python egg for API
dist_egg_api: 
	cd $(API_PATH)alfanous ; python setup.py bdist_egg 
	mkdir -p output/$(VERSION) ; mv $(API_PATH)alfanous/dist/*.egg ./output/$(VERSION)
	@echo  "NOTE: you can find the generated egg in ./output"
	
# python egg for PyCorpus extension
dist_egg_pycorpus: 
	cd $(API_PATH)PyCorpus ; python setup.py bdist_egg 
	mkdir -p output/$(VERSION) ; mv $(API_PATH)PyCorpus/dist/*.egg ./output/$(VERSION)
	@echo  "NOTE: you can find the generated egg in ./output"
	

# python egg for PyZekrModels extension
dist_egg_pyzekr: 
	cd $(API_PATH)PyZekrModels ; python setup.py bdist_egg 
	mkdir -p output/$(VERSION) ; mv $(API_PATH)PyZekrModels/dist/*.egg ./output/$(VERSION)
	@echo  "NOTE: you can find the generated egg in ./output"
	
# python egg for Qimport extension
dist_egg_qimport: 
	cd $(API_PATH)alfanous-import ; python setup.py bdist_egg 
	mkdir -p output/$(VERSION) ; mv $(API_PATH)alfanous-import/dist/*.egg ./output/$(VERSION)
	@echo  "NOTE: you can find the generated egg in ./output"

# python egg for alfanousDesktop interface
dist_egg_desktop: 
	cd $(DESKTOP_INTERFACE_PATH) ; python setup.py bdist_egg 
	mkdir -p output/$(VERSION) ; mv $(DESKTOP_INTERFACE_PATH)dist/*.egg ./output/$(VERSION)
	@echo  "NOTE: you can find the generated egg in ./output"
 
# Debian package for AlfanousDesktop
dist_deb: 
	dpkg-buildpackage
	

# Fedora package for AlfanousDesktop
dist_rpm:  
	@echo "todo"
	#cd $(DESKTOP_INTERFACE_PATH) ; python setup.py bdist_rpm
	#cd $(DESKTOP_INTERFACE_PATH) ; python setup.py bdist_rpm 
	
# MacOs application 
## need distutils  and py2app 
## apt-get install python-distutils*
## easy_install py2app
dist_app:  
	@echo "todo using py2app"
	# cd $(DESKTOP_INTERFACE_PATH) ; python setup.py py2app

# Nokia symbian package for alfanousPyS60 #required python2.5 
dist_sis: 
	 #work only with python2.5
	 #cd ./interfaces/mobile/Nokia\ S60/alfanousS60 ; python2.5 ensymble.py py2sis --uid=0x07342651 --appname=AlfanousS60 --version=$(VERSION) --lang=EN  --caption="Alfanous - Quranic Search Engine" --vendor="Alfanous.org" main.py AlfanousS60.sis #--icon=icon.svg  --cert=mycert.cer --privkey=mykey.key  
	 @echo "todo"
	
	
# Firefox toolbar
dist_xpi:
	cd ./interfaces/toolbars/firefox/chrome ; zip -r alfanoustoolbar.jar content/* skin/*
	cd ./interfaces/toolbars/firefox ; zip alfanous_toolbar_$(VERSION).xpi install.rdf chrome.manifest defaults/* chrome/alfanoustoolbar.jar
	mkdir -p output/$(VERSION) ; mv ./interfaces/toolbars/firefox/alfanous_toolbar_$(VERSION).xpi ./output/$(VERSION)


## install all (deprecated), use it only to make tests:
# 1. the API, see install_api
# 2. the desktop inteface, see install_desktop
# 3. the json web service II, see install_json2
# 4. the web interface, see install_web	
install_all: install_api install_desktop install_jos2 install_web


install_api: 
	cd   "$(API_PATH)alfanous" ; python setup.py  install
	
install_desktop:  install_api qt_all  local_mo_download
	cd  $(DESKTOP_INTERFACE_PATH); sudo python setup.py install
	cp ./resources/launchers/alfanousDesktop $(DESTDIR)$(PREFIX)/bin/
	cp ./resources/launchers/alfanous.desktop $(DESTDIR)$(PREFIX)/share/applications/
	cp ./resources/AlFanous.png  $(DESTDIR)$(PREFIX)/share/pixmaps/
	cp ./resources/fonts/* $(DESTDIR)$(PREFIX)/share/fonts/
	#test installation
	alfanousDesktop &
	

install_web_basic:
	#rm -r  $(WEB_INSTALL_PATH)
	mkdir -p $(WEB_INSTALL_PATH)
	chmod 755 -R $(WEB_INSTALL_PATH)
	#cd ./interfaces/web/ ;  cp  htaccess $(WEB_INSTALL_PATH)".htaccess"
	cd ./interfaces/web/ ;  vi alfanous ; cp alfanous /etc/apache2/sites-available/ #configure well this file 

	a2dissite alfanous
	a2ensite alfanous
	service apache2 reload

	if ! grep -qs alfanous.local /etc/hosts; then   echo "127.0.0.1 alfanous.local" >> /etc/hosts ; fi


install_jos2: install_api install_web_basic
	cd $(API_PATH)alfanous-cgi ;  mkdir -p $(WEB_CGI_INSTALL_PATH).alfanous/; cp  -r alfanous_json2.py $(WEB_CGI_INSTALL_PATH);
	chmod +x $(WEB_CGI_INSTALL_PATH)alfanous_json2.py
	chmod -R 777 $(WEB_CGI_INSTALL_PATH).alfanous/
	sed -i 's/\"cgitb.enable\(\)\"/cgitb.enable\(\)/g' "$(WEB_CGI_INSTALL_PATH)alfanous_json2.py"
	xdg-open http://alfanous.local/cgi-bin/alfanous_json2.py &  ##launch default browser for test


install_wui: install_jos2
	cd ./interfaces/web/ ;  cp  -r wui  $(WEB_INSTALL_PATH) 
	cd $(WEB_INSTALL_PATH);  cd wui; sed -i 's/www\.alfanous\.org\/json2/alfanous\.local\/cgi\-bin\/alfanous\_json2\.py/g' index.*
	xdg-open http://alfanous.local/ &  ##launch default browser for test

