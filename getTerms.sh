TSV_DIR=/Users/smr/src/ontology/SIMR_ONTOLOGY/simr/src/patterns/data/default

#for i in EFO UO UBERON CL CLO ERO GO MS NCIT RO CHEBI FBbi MI NCBITaxon OBI
for i in EFO 
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
    fi
    if [ -s "$i.list" ]; then
      echo "  extracting terms for $i"
      if [ $PREFIX == "efo" ];then
        robot extract --method BOT --input $PREFIX.owl --term-file $i.list --output ${PREFIX}_import.owl
       else
        robot extract --method BOT --input $PREFIX.owl --term-file $i.list --output ${PREFIX}_import.owl
       fi
    else
      echo "  $i.list is empty"
    fi
 done

