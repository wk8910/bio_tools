zcat ds_150.wig.mapQ.gz | awk '$4==1' | cut -f 1-3 > keepPos.bed
