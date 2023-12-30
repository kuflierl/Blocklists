while IFS="" read -r p || [ -n "$p" ]
do
  [[ "$p" =~ ^domain(black|white)list (text|web)source \w+(\/\w+)*$ ]] || continue
  firstparam=`echo $p | awk '{print $1;}')`
  secondparam=`echo $p | awk '{print $2;}')`
  thirdparam=`echo $p | awk '{print $3;}')`
  out="./build/$secondparam/$thirdparam.$firstparam"
  echo "$out"
done < $1
