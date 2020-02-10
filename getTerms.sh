TSV_DIR=/Users/smr/src/ontology/SIMR_ONTOLOGY/simro/src/patterns/data/default
DEFOWL=/Users/smr/src/ontology/SIMR_ONTOLOGY/simro/src/patterns/definitions.owl

for i in PR ERO CLO EFO UBERON NCIT NCBITaxon

  do
    PREFIX=`echo $i | perl -ne "print lc"`
    echo "processing $i"
    echo "  getting owl for $i"
    if [ ! -e $PREFIX.owl ] ; then
      if [ $PREFIX == "efo" ] ; then
        curl -OL http://www.ebi.ac.uk/efo/efo.owl
      else
        echo "curl -OL http://purl.obolibrary.org/obo/$PREFIX.owl"
        curl -OL http://purl.obolibrary.org/obo/$PREFIX.owl
      fi
    fi
    echo "  done getting owl for $i"

    if [ $PREFIX == "efo" ];then
      echo "  finding terms for $i"
      grep ${i}: $TSV_DIR/*tsv | perl -p -e 's/.+'$i'\:(\S+).*/http:\/\/www.ebi.ac.uk\/efo\/EFO_$1/g' | sort | uniq > EFO.list
    else
      echo "  finding terms for $i "
      grep ${i}: $TSV_DIR/*tsv | perl -p -e 's/.+'$i'\:(\S+).*/http:\/\/purl.obolibrary.org\/obo\/'$i'_$1/g' | sort | uniq > $i.list 
      if [ -f $i.manual_addition.list ] ; then
        cat $i.list $i.manual_addition.list | sort | uniq > $i.list
      fi
      grep ${i}_ $DEFOWL | perl -p -e 's/.+('$i'_\S+)>.*/http:\/\/purl.obolibrary.org\/obo\/$1/g' | sort | uniq >> $i.list 
    fi
    if [ -s "$i.list" ]; then
      echo "  extracting terms for $i"
      export ROBOT_JAVA_ARGS=-Xmx12G
      if [ $PREFIX == "efo" ];then
        robot extract --method BOT --input $PREFIX.owl --term-file $i.list --output ${PREFIX}_import.owl
       else
        robot extract --method BOT --input $PREFIX.owl --term-file $i.list --output ${PREFIX}_import.owl
       fi
    else
      echo "  $i.list is empty"
    fi
 done


 # get rid of has_specified_input annotations
 for i in CLO 
    do
      PREFIX=`echo $i | perl -ne "print lc"`
      robot remove --input ${PREFIX}_import.owl -t CLO:0000015 -t OBI:0000293 --preserve-structure false annotate --ontology-iri http://purl.obolibrary.org/obo/simro/imports/${PREFIX}_import.owl --output ${PREFIX}_import.owl.tmp.owl 
      #mv ${PREFIX}_import.owl.tmp.owl ${PREFIX}_import.owl
    done

